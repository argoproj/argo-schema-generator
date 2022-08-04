### Description
This repo contains a tool that generates a kustomize schema file for native kubernetes resources plus projects under the 
argoproj name including Argo CD, Argo Rollouts, Argo Workflows, and Argo Events.

### How to run
To run the tool, run the following command:
```
make gen-openapi-schema
```

### How to use
In your kustomization.yaml file add a config block like

#### Using main branch:
```
openapi:
  path: https://raw.githubusercontent.com/argoproj/argo-schema-generator/main/schema/argo_all_k8s_kustomize_schema.json
```
#### Using a specific tag:
```
openapi:
  path: https://github.com/argoproj/argo-schema-generator/raw/2022-08-04-1659642986/schema/argo_all_k8s_kustomize_schema.json
```

### Github Action
There is a Github action set to run on the first of each month that will update the schema's. This action can 
also be manually run to update definitions. It will also create a tag.