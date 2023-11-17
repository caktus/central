# Download packages we need to copy to the Windows servers manually:
helm:
	python -m venv /tmp/odk-central-venv/
	/tmp/odk-central-venv/bin/pip install oyaml
	/tmp/odk-central-venv/bin/python generate_helm.py > docker-compose.helm.yml
	kompose convert -f docker-compose.helm.yml -c
	rm -rf /tmp/odk-central-venv/

.PHONY: helm
