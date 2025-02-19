#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Usage: $ ./up.sh

set -e

# Change working directory to integration
project_root=$(git rev-parse --show-toplevel)
cd "${project_root}"/integration/airflow/tests/integration

if [[ "$(docker images -q openlineage-airflow-base:latest 2> /dev/null)" == "" ]]; then
  echo "Please run 'docker build -f Dockerfile.tests -t openlineage-airflow-base .' at base folder"
  exit 1
fi

if [[ ! -f gcloud/gcloud-service-key.json ]]; then
  mkdir -p gcloud
fi
if [[ -n "$CI" ]]; then
  echo $GCLOUD_SERVICE_KEY > gcloud/gcloud-service-key.json
  chmod 644 gcloud/gcloud-service-key.json
fi

# maybe overkill
OPENLINEAGE_AIRFLOW_WHL=$(docker run openlineage-airflow-base:latest sh -c "ls /whl/openlineage*")
OPENLINEAGE_AIRFLOW_WHL_ALL=$(docker run openlineage-airflow-base:latest sh -c "ls /whl/*")

# Add revision to requirements.txt
cat > requirements.txt <<EOL
airflow-provider-great-expectations==0.0.8
great-expectations==0.13.42
dbt-bigquery==0.20.1
${OPENLINEAGE_AIRFLOW_WHL}
EOL


# Add revision to integration-requirements.txt
cat > integration-requirements.txt <<EOL
requests==2.24.0
setuptools==34.0.0
psycopg2-binary==2.9.2
httplib2>=0.18.1
retrying==1.3.3
pytest==6.2.2
jinja2==3.0.2
python-dateutil==2.8.2
${OPENLINEAGE_AIRFLOW_WHL}
EOL

docker-compose down
docker-compose up -V --build --force-recreate --exit-code-from integration
