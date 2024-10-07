import { Construct } from "constructs";
import { CloudRunService } from "@cdktf/provider-google/lib/cloud-run-service";
import { CloudRunServiceIamMember } from "@cdktf/provider-google/lib/cloud-run-service-iam-member";
import { TerraformOutput } from "cdktf";

export interface CloudRunProps {
  projectName: string;
  region: string;
  projectId: string;
}

export class CloudRunModule extends Construct {
  public readonly service: CloudRunService;

  constructor(scope: Construct, id: string, props: CloudRunProps) {
    super(scope, id);

    this.service = new CloudRunService(this, "cloudrun", {
      name: `${props.projectName}-service`,
      location: props.region,
      template: {
        spec: {
          containers: [{
            image: `${props.region}-docker.pkg.dev/${props.projectId}/${props.projectName}/${props.projectName}:latest`,
            ports: [{
              containerPort: 5000
            }],
            resources: {
              requests: {
                memory: "2Gi"
              },
              limits: {
                memory: "2Gi"
              },
            },
          }]
        }
      }
    });

    new CloudRunServiceIamMember(this, "all_users", {
      service: this.service.name,
      location: this.service.location,
      role: "roles/run.invoker",
      member: "allUsers"
    });

    new TerraformOutput(this, "cloudrun_url", {
      value: this.service.status.get(0).url,
      description: "The URL of the deployed Cloud Run service"
    });
  }
}
