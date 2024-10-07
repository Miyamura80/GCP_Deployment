import { Construct } from "constructs";
import { ArtifactRegistryRepository } from "@cdktf/provider-google/lib/artifact-registry-repository";

export interface ArtifactRegistryProps {
  region: string;
  projectName: string;
}

export class ArtifactRegistryModule extends Construct {
  public readonly repository: ArtifactRegistryRepository;

  constructor(scope: Construct, id: string, props: ArtifactRegistryProps) {
    super(scope, id);

    this.repository = new ArtifactRegistryRepository(this, "hackbot_website", {
      location: props.region,
      repositoryId: props.projectName,
      format: "DOCKER",
      description: "Docker repository for storing container images",
    });
  }
}
