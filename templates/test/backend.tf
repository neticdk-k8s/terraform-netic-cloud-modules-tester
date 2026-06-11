# State-nøglen sættes bevidst IKKE her — den skal angives pr. template ved init,
# så to templates aldrig deler (og overskriver) samme state-fil:
#   tofu init -backend-config="key=<template>_<cloud>_<branch>/tofu.tfstate"
# Workflowet gør dette automatisk.
terraform {
  backend "s3" {
    bucket = "terraformstate09999"
    region = "gra"

    endpoints = {
      s3 = "https://s3.gra.io.cloud.ovh.net"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}
