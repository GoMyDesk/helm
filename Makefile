## make package-chart  # Packages the helm chart.
package-chart:
	cd charts && helm package gomydesk

## make package-index  # Create the helm repo package index.
package-index:
	cd charts && helm repo index .

## make helm-docs      # Generates the helm chart documentation.
helm-docs:
	docker run --rm -v "$(CURDIR)/charts/gomydesk:/helm-docs" -u $(shell id -u) jnorwood/helm-docs:latest
