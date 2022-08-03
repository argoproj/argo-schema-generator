PACKAGE=github.com/argoproj/argo-rollouts
CURRENT_DIR=$(shell pwd)
DIST_DIR=${CURRENT_DIR}/dist

.PHONY: gen-schema-only
gen-schema-only:
	go run cmd/gen-schema/main.go

.PHONY: gen-all-schema
gen-schema: gen-openapi gen-workflows-schema gen-events-schema gen-cd-schema
	go run cmd/gen-schema/main.go

.PHONY: gen-openapi
gen-openapi: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--input-dirs github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1,github.com/argoproj/argo-workflows/v3/pkg/apis/workflow/v1alpha1,github.com/argoproj/argo-events/pkg/apis/eventsource/v1alpha1,github.com/argoproj/argo-events/pkg/apis/eventbus/v1alpha1,github.com/argoproj/argo-events/pkg/apis/sensor/v1alpha1,github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1,k8s.io/api/admission/v1,k8s.io/api/admissionregistration/v1,k8s.io/api/admissionregistration/v1beta1,k8s.io/api/authentication/v1,k8s.io/api/apiregistration/v1,k8s.io/api/apps/v1,k8s.io/api/apps/v1beta1,k8s.io/api/apps/v1beta2,k8s.io/api/autoscaling/v1beta1,k8s.io/api/autoscaling/v1,k8s.io/api/autoscaling/v2,k8s.io/api/batch/v1,k8s.io/api/batch/v1beta1,k8s.io/api/certificates/v1beta1,k8s.io/api/certificates/v1,k8s.io/api/core/v1,k8s.io/api/extensions/v1beta1,k8s.io/api/networking/v1,k8s.io/api/networking/v1beta1,k8s.io/api/policy/v1,k8s.io/api/policy/v1beta1,k8s.io/api/rbac/v1,k8s.io/api/rbac/b1beta1,k8s.io/api/rbac/v1alpha1,k8s.io/api/storage/v1,k8s.io/api/storage/v1alpha1,k8s.io/api/storage/v1beta1 \
		--output-package pkg/apis/ \
		--report-filename pkg/apis/violation_exceptions.list \
		-o ${CURRENT_DIR}

.PHONY: gen-workflows-schema
gen-workflows-schema: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--input-dirs github.com/argoproj/argo-workflows/v3/pkg/apis/workflow/v1alpha1  \
		--output-package pkg/workflows/ \
		--report-filename pkg/workflows/violation_exceptions.list \
		-o ${CURRENT_DIR}

.PHONY: gen-events-schema
gen-events-schema: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--input-dirs github.com/argoproj/argo-events/pkg/apis/eventsource/v1alpha1,github.com/argoproj/argo-events/pkg/apis/eventbus/v1alpha1,github.com/argoproj/argo-events/pkg/apis/sensor/v1alpha1  \
		--output-package pkg/events/ \
		--report-filename pkg/events/violation_exceptions.list \
		-o ${CURRENT_DIR}

.PHONY: gen-cd-schema
gen-cd-schema: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--input-dirs github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1 \
		--output-package pkg/cd/ \
		--report-filename pkg/cd/violation_exceptions.list \
		-o ${CURRENT_DIR}

.PHONY: gen-rollouts-schema
gen-rollouts-schema: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--input-dirs github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1 \
		--output-package pkg/cd/ \
		--report-filename pkg/cd/violation_exceptions.list \
		-o ${CURRENT_DIR}

.PHONY: install-tools
install-tools:
	./hack/install-tools.sh