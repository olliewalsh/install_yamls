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

if [ -z "$OUT" ]; then
  echo "Please set OUT"; exit 1
fi

if [ -z "$NAMESPACE" ]; then
  echo "Please set NAMESPACE"; exit 1
fi

OUT_DIR=${OUT}/${NAMESPACE}

if [ ! -d ${OUT_DIR} ]; then
  mkdir -p ${OUT_DIR}
fi

# can share this for all the operators, won't get re-applied if it already exists
cat > ${OUT_DIR}/ca.yaml <<EOF_CAT
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${NAMESPACE}-issuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${NAMESPACE}-ca
  namespace: ${NAMESPACE}
spec:
  isCA: true
  commonName: ${NAMESPACE}-ca
  secretName: ${NAMESPACE}-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: ${NAMESPACE}-issuer
    kind: ClusterIssuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${NAMESPACE}-ca-issuer
  namespace: ${NAMESPACE}
spec:
  ca:
    secretName: ${NAMESPACE}-ca-secret
EOF_CAT
