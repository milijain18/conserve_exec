
PROJECT_ID=$(shell gcloud config get-value core/project)
all:
	@echo "build  - Build the docker image"
	@echo "deploy - Deploy the image to Cloud Run"
	@echo "clean  - Clean resoruces created in this test"
	@echo "call   - Call the Cloud Run service"

deploy:
	gcloud run deploy conserve_exec \
		--image gcr.io/$(PROJECT_ID)/conserve_exec \
		--max-instances 1 \
		--platform managed \
		--region us-central1 \
		--no-allow-unauthenticated

build:
	gcloud builds submit --tag gcr.io/$(PROJECT_ID)/conserve_exec

clean:
	-gcloud container images delete gcr.io/$(PROJECT_ID)/conserve_exec --quiet
	-gcloud run services delete conserve_exec \
		--platform managed \
		--region us-central1 \
		--quiet

call:
	@echo "Calling Python Cloud Run service"
	@url=$(shell gcloud run services describe conserve_exec --format='value(status.url)' --region us-central1 --platform managed); \
	token=$(shell gcloud auth print-identity-token); \
	curl --request POST \
  		--header "Authorization: Bearer $$token" \
  		--header "Content-Type: text/plain" \
  		$$url/exec \
  		--data-binary "ps -ef"
