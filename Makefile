PACKAGE=github.com/argoproj/argo-rollouts
CURRENT_DIR=$(shell pwd)
DIST_DIR=${CURRENT_DIR}/dist

.PHONY: gen-openapi
gen-openapi: $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
    		pkg/apis/rollouts/... \
    		--go-header-file hack/custom-boilerplate.go.txt \
    		--input-dirs github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1,github.com/argoproj/argo-workflows/v3/pkg/apis/workflow/v1alpha1,github.com/argoproj/argo-events/pkg/apis/eventsource/v1alpha1,github.com/argoproj/argo-events/pkg/apis/eventbus/v1alpha1,github.com/argoproj/argo-events/pkg/apis/sensor/v1alpha1,github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1,k8s.io/api/admission/v1,k8s.io/api/admissionregistration/v1,k8s.io/api/admissionregistration/v1beta1,k8s.io/api/authentication/v1,k8s.io/api/apiregistration/v1,k8s.io/api/apps/v1,k8s.io/api/apps/v1beta1,k8s.io/api/apps/v1beta2,k8s.io/api/autoscaling/v1beta1,k8s.io/api/autoscaling/v1,k8s.io/api/autoscaling/v2,k8s.io/api/batch/v1,k8s.io/api/batch/v1beta1,k8s.io/api/certificates/v1beta1,k8s.io/api/certificates/v1,k8s.io/api/core/v1,k8s.io/api/extensions/v1beta1,k8s.io/api/networking/v1,k8s.io/api/networking/v1beta1,k8s.io/api/policy/v1,k8s.io/api/policy/v1beta1,k8s.io/api/rbac/v1,k8s.io/api/rbac/b1beta1,k8s.io/api/rbac/v1alpha1,k8s.io/api/storage/v1,k8s.io/api/storage/v1alpha1,k8s.io/api/storage/v1beta1 \
    		--output-package pkg/apis/ \
    		--report-filename violation_exceptions.list \
    		-o ${CURRENT_DIR}

.PHONY: install-tools
install-tools:
	./hack/install-tools.sh