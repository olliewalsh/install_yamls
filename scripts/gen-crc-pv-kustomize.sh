#!/bin/bash
#
# Copyright 2022 Red Hat Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
set -ex

if [ ! -d out/crc/storage ]; then
  mkdir -p out/crc/storage
fi

NODE_NAME=$(oc get node -o name | sed -e 's|node/||')
if [ -z "$NODE_NAME" ]; then
  echo "Unable to determine node name with 'oc' command."
  exit 1
fi

cat > out/crc/storage/kustomization.yaml <<EOF_CAT
resources:
- ../../../crc/storage
patches:
- patch: |-
    - op: replace
      path: /spec/nodeAffinity/required/nodeSelectorTerms/0/matchExpressions/0/values/0
      value: $NODE_NAME
  target:
    kind: PersistentVolume
EOF_CAT
