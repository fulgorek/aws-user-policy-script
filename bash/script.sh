#!/usr/bin/env bash

REGION=us-west-2

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -u|--username)
    USERNAME="$2"
    shift
    shift
    ;;
    -p|--policy)
    POLICY="$2"
    shift
    shift
    ;;
    -f|--policy-file)
    POLICY_FILE="$2"
    shift
    shift
    ;;
    --attach)
    ATTACH=YES
    shift
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"


type aws &>/dev/null
[[ $? -ne 0 ]] && echo "aws-cli not found..." && exit 1

ACCOUNT=$(aws sts get-caller-identity --region ${REGION} --output text | awk '{print $1}')
[[ ${ACCOUNT} == "" ]] && echo "Unable to locate credentials" && exit 1

aws iam get-user --user-name ${USERNAME} &>/dev/null
if [[ $? -eq 0 ]]; then
    echo "user ${USERNAME} already exists..."
else
    aws iam create-user --user-name ${USERNAME} &>/dev/null && echo "created user ${USERNAME}..."
fi

POLICY_EXIST=$(aws iam get-policy --policy-arn arn:aws:iam::${ACCOUNT}:policy/${POLICY} --output text 2>/dev/null)
if [[ ${POLICY_EXIST} == "" ]]; then
    [[ ! -f ${POLICY_FILE} ]] && echo "policy file not found in ${POLICY_FILE}" && exit 1
    echo "creating new policy: ${POLICY}..."
    aws iam create-policy --policy-name ${POLICY} --policy-document file://${POLICY_FILE} &>/dev/null
    [[ $? -eq 0 ]] && echo "policy ${POLICY} created successfully."
else
    echo "policy ${POLICY} already exists..."
fi

if [[ ${USERNAME} != ""  && ${ATTACH} == "YES" ]]; then
    ATTACHED=$(aws iam list-attached-user-policies --user-name ${USERNAME} --query 'AttachedPolicies[].PolicyName' --output text | grep ${POLICY})
    [[ $? -eq 0 ]] && echo "policy ${POLICY} already attached to ${USERNAME}..." && exit 1
    echo "attaching policy ${POLICY} to ${USERNAME}"
    aws iam attach-user-policy --policy-arn arn:aws:iam::${ACCOUNT}:policy/testd --user-name ${USERNAME} &>/dev/null
    [[ $? -eq 0 ]] && echo "Success: policy ${POLICY} attached to ${USERNAME}"
fi
