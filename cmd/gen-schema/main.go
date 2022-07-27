package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os/exec"
	"strings"

	"github.com/zachaller/argo-schema-generator/pkg/apis"
	kubeopenapiutil "k8s.io/kube-openapi/pkg/util"
	kOpenAPISpec "k8s.io/kube-openapi/pkg/validation/spec"

	semver "github.com/blang/semver/v4"
)

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}

type xKubernetesGroupVersionKind struct {
	Group   string `json:"group"`
	Kind    string `json:"kind"`
	Version string `json:"version"`
}
type gvkMeta struct {
	XKubernetesGroupVersionKind []xKubernetesGroupVersionKind `json:"x-kubernetes-group-version-kind"`
}
type k8sGvkMapping struct {
	Definitions map[string]gvkMeta `json:"definitions"`
}

type openAPISchema struct {
	kOpenAPISpec.Schema
	XKubernetesGroupVersionKind []xKubernetesGroupVersionKind `json:"x-kubernetes-group-version-kind"`
}

//Add marshal function so we don't call the embeeded marshal
func (s openAPISchema) MarshalJSON() ([]byte, error) {
	b1, err := json.Marshal(s.Schema)
	if err != nil {
		return nil, fmt.Errorf("schema %v", err)
	}

	if s.XKubernetesGroupVersionKind != nil {
		b2, err := json.Marshal(s.XKubernetesGroupVersionKind)
		if err != nil {
			return nil, fmt.Errorf("x-kubernetes-group-version-kind %v", err)
		}
		b1 = append(b1[:len(b1)-1], fmt.Sprintf(",\"x-kubernetes-group-version-kind\":%s}", string(b2))...)
	}
	return b1, nil
}

// loadK8SDefinitions loads K8S types API schema definitions starting with the version specified in go.mod then the fucnction
// parameter versions
func loadK8SDefinitions(versions []int) (*k8sGvkMapping, error) {
	// detects minor version of k8s client
	k8sVersionCmd := exec.Command("sh", "-c", "cat go.mod | grep \"k8s.io/client-go\" |  head -n 1 | cut -d' ' -f2")
	versionData, err := k8sVersionCmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to determine k8s client version: %v", err)
	}
	v, err := semver.Parse(strings.TrimSpace(strings.Replace(string(versionData), "v", "", 1)))
	if err != nil {
		return nil, err
	}

	resp, err := http.Get(fmt.Sprintf("https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.%d/api/openapi-spec/swagger.json", v.Minor))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	schemaGoMod := k8sGvkMapping{}
	err = json.Unmarshal(data, &schemaGoMod)
	if err != nil {
		return nil, err
	}

	for _, v := range versions {
		//Download fixe old version to keep old schema's compatibility
		resp, err = http.Get(fmt.Sprintf("https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.%d/api/openapi-spec/swagger.json", v))
		if err != nil {
			return nil, err
		}
		data, err = ioutil.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			return nil, err
		}

		schemaFixedVer := k8sGvkMapping{}
		err = json.Unmarshal(data, &schemaFixedVer)
		if err != nil {
			return nil, err
		}

		//Merge old and new schema
		for k, v := range schemaFixedVer.Definitions {
			schemaGoMod.Definitions[k] = v
		}
	}

	return &schemaGoMod, nil
}

func generateOpenApiSchema(outputPath string) error {
	// We replace the generated names with group specific names aka argocd is `argocd.argoproj.io` instead of the real
	// group kind because within all the argo projects we have overlapping types due to all argo projects being under the same
	// argoproj.io group. Kustomize does not care about the name as long as all the links match up and the `x-kubernetes-group-version-kind`
	// metadata is correct.
	var argoMappings = map[string]string{
		"github.com/argoproj/argo-cd/v2/pkg/apis/application":     "argocd.argoproj.io",
		"github.com/argoproj/argo-events/pkg/apis/eventbus":       "eventbus.argoproj.io",
		"github.com/argoproj/argo-events/pkg/apis/eventsource":    "eventsource.argoproj.io",
		"github.com/argoproj/argo-events/pkg/apis/sensor":         "sensor.argoproj.io",
		"github.com/argoproj/argo-rollouts/pkg/apis/rollouts":     "rollouts.argoproj.io",
		"github.com/argoproj/argo-workflows/v3/pkg/apis/workflow": "workflow.argoproj.io",
	}

	d := apis.GetOpenAPIDefinitions(func(path string) kOpenAPISpec.Ref {
		for k, v := range argoMappings {
			path = strings.ReplaceAll(path, k, v)
		}
		return kOpenAPISpec.MustCreateRef(fmt.Sprintf("#/definitions/%s", kubeopenapiutil.ToRESTFriendlyName(path)))
	})

	var def = make(map[string]openAPISchema)
	for pathKey, definition := range d {
		for k, v := range argoMappings {
			pathKey = strings.ReplaceAll(pathKey, k, v)
		}
		def[kubeopenapiutil.ToRESTFriendlyName(pathKey)] = openAPISchema{
			Schema:                      definition.Schema,
			XKubernetesGroupVersionKind: make([]xKubernetesGroupVersionKind, 0),
		}
	}

	k8sDefs, err := loadK8SDefinitions([]int{18, 21, 24})
	checkErr(err)
	for k, v := range def {
		//We pull out argo crd information based on the dot pattern of the key in the dictionary we are also setting it for all
		//argo types instead of just the ones needed this could be incorrect as far as spec goes, but it works.
		if strings.HasPrefix(k, "io.argoproj") {
			argoGVK := strings.Split(k, ".")
			v.XKubernetesGroupVersionKind = []xKubernetesGroupVersionKind{{
				Group:   "argoproj.io",
				Kind:    argoGVK[4],
				Version: argoGVK[3],
			}}
			def[k] = v
			continue
		}

		// Pull the group version kind information from the k8s definitions that we downloaded via loadK8SDefinitions
		entry, ok := k8sDefs.Definitions[k]
		if ok {
			e, ok := def[k]
			if ok {
				if len(entry.XKubernetesGroupVersionKind) > 0 {
					e.XKubernetesGroupVersionKind = entry.XKubernetesGroupVersionKind
					def[k] = e
				}
			}
		}

	}

	data, err := json.MarshalIndent(map[string]interface{}{
		"definitions": def,
	}, "", "    ")
	if err != nil {
		return err
	}

	return ioutil.WriteFile(outputPath, data, 0644)
}

// Generate CRD spec for Rollout Resource
func main() {
	err := generateOpenApiSchema("schema/argo_kustomize_schema.json")
	checkErr(err)
}
