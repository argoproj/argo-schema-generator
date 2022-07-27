//go:build tools
// +build tools

package tools

import (
	// used in `make gen-openapi`
	_ "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
	_ "github.com/argoproj/argo-events/pkg/apis/eventbus/v1alpha1"
	_ "github.com/argoproj/argo-events/pkg/apis/eventsource/v1alpha1"
	_ "github.com/argoproj/argo-events/pkg/apis/sensor/v1alpha1"
	_ "github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1"
	_ "github.com/argoproj/argo-workflows/v3/pkg/apis/workflow/v1alpha1"
	_ "k8s.io/api"
	_ "k8s.io/kube-openapi/cmd/openapi-gen"
)
