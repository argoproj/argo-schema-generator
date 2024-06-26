PACKAGE=github.com/argoproj/argo-rollouts
CURRENT_DIR=$(shell pwd)
DIST_DIR=${CURRENT_DIR}/dist

.PHONY: gen-schema-only
gen-schema-only:
	go run cmd/gen-schema/main.go

.PHONY: gen-openapi-schema
gen-openapi-schema: gen-all-openapi gen-workflows-openapi gen-events-openapi gen-cd-openapi gen-rollouts-openapi
	go run cmd/gen-schema/main.go

.PHONY: gen-all-openapi
gen-all-openapi: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--output-pkg pkg/apis/ \
		--output-file pkg/apis/openapi_generated.go \
		--report-filename pkg/apis/violation_exceptions.list \
		--output-dir ${CURRENT_DIR} \
		github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1 github.com/argoproj/argo-workflows/v3/pkg/apis/workflow/v1alpha1 github.com/argoproj/argo-events/pkg/apis/eventsource/v1alpha1 github.com/argoproj/argo-events/pkg/apis/eventbus/v1alpha1 github.com/argoproj/argo-events/pkg/apis/sensor/v1alpha1 github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1 k8s.io/api/admission/v1 k8s.io/api/admissionregistration/v1 k8s.io/api/admissionregistration/v1beta1 k8s.io/api/authentication/v1 k8s.io/api/apps/v1 k8s.io/api/apps/v1beta1 k8s.io/api/apps/v1beta2 k8s.io/api/autoscaling/v1 k8s.io/api/autoscaling/v2 k8s.io/api/batch/v1 k8s.io/api/batch/v1beta1 k8s.io/api/certificates/v1beta1 k8s.io/api/certificates/v1 k8s.io/api/core/v1 k8s.io/api/extensions/v1beta1 k8s.io/api/networking/v1 k8s.io/api/networking/v1beta1 k8s.io/api/policy/v1 k8s.io/api/policy/v1beta1 k8s.io/api/rbac/v1 k8s.io/api/rbac/v1beta1 k8s.io/api/rbac/v1alpha1 k8s.io/api/storage/v1 k8s.io/api/storage/v1alpha1 k8s.io/api/storage/v1beta1


.PHONY: gen-workflows-openapi
gen-workflows-openapi: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--output-pkg pkg/workflows/ \
		--output-file pkg/workflows/openapi_generated.go \
		--report-filename pkg/workflows/violation_exceptions.list \
		--output-dir ${CURRENT_DIR} \
		github.com/argoproj/argo-workflows/v3/pkg/apis/workflow/v1alpha1

.PHONY: gen-events-openapi
gen-events-openapi: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--output-pkg pkg/events/ \
		--output-file pkg/events/openapi_generated.go \
		--report-filename pkg/events/violation_exceptions.list \
		--output-dir ${CURRENT_DIR} \
		github.com/argoproj/argo-events/pkg/apis/eventsource/v1alpha1 github.com/argoproj/argo-events/pkg/apis/eventbus/v1alpha1 github.com/argoproj/argo-events/pkg/apis/sensor/v1alpha1

.PHONY: gen-cd-openapi
gen-cd-openapi: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--output-pkg pkg/cd/ \
		--output-file pkg/cd/openapi_generated.go \
		--report-filename pkg/cd/violation_exceptions.list \
		--output-dir ${CURRENT_DIR} \
		github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1


.PHONY: gen-rollouts-openapi
gen-rollouts-openapi: install-tools $(DIST_DIR)/openapi-gen
	PATH=${DIST_DIR}:$$PATH openapi-gen \
		--go-header-file hack/custom-boilerplate.go.txt \
		--output-pkg pkg/rollouts/ \
		--output-file pkg/rollouts/openapi_generated.go \
		--report-filename pkg/rollouts/violation_exceptions.list \
		--output-dir ${CURRENT_DIR} \
		github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1

.PHONY: install-tools
install-tools:
	./hack/install-tools.sh
