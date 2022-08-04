project = "kubernetes-nodejs-ingress"

app "nodejs-ingress-app" {
  labels = {
    "service" = "nodejs-ingress-app",
    "env"     = "dev"
  }

  build {
    use "pack" {
        builder     = "heroku/buildpacks:20"
    }
    registry {
      use "docker" {
        image = "razvanmoj/nodejs-ingress-app"
        tag   = gitrefpretty()
        local = false
        username = "aaa"
        password = "aaa"
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path = "/"
      # namespace = "nodejs"
    }
  }

  release {
    use "kubernetes" {
      namespace = "waypoint"
      ingress "http" {
        path_type = "Prefix"
        path      = "/"
        host      = "nodejs.apps.raz-test.cloud-platform.service.justice.gov.uk"
        annotations = {
            "kubernetes.io/ingress.class" = "nginx"
        }
      }
    }
  }
}
