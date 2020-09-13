

provider "kubernetes" {
   

    config_context_cluster="gke_${google_container_cluster.my-cluster.project}_${google_container_cluster.my-cluster.location}_${google_container_cluster.my-cluster.name}"
}

resource "kubernetes_service" "kube-service" {


    metadata{

        name="kube-service"
        
        labels={
            
            env="test"
            name="kube-service"
        }
    }

    spec{


    type="LoadBalancer"
     
     selector={

     app="gcp-wp"
   

     }

     port{

         port=80
         target_port=80
      
     }

    
    }
}

output "svc_ip"{

    value=kubernetes_service.kube-service.load_balancer_ingress[0].ip
}


// schedule deployment

resource "kubernetes_deployment" "tf-kube-wp"{


    metadata{

        name="tf-kube-wp"
        labels={
            name="tf-kube-wp"
            app="gcp-wp"
        }
    }

    spec{
      replicas=1
      selector{
          match_labels = {
         app="gcp-wp"
      }
 
         
      }
      template{

          metadata{

              name="pod-wp"
              labels={
                  app="gcp-wp"
              
          }
          }
              spec{

                container{
                    name="con-wp"
                    image="wordpress"
                    
                }
              }
      }
    }
}

// launch wordpress

resource "null_resource" "launch_wp" {

    provisioner "local-exec" {

        command ="open -a \"google chrome\" http://${kubernetes_service.kube-service.load_balancer_ingress[0].ip}"
    }
}