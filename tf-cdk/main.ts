import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";

// Import custom variables
import { Variables } from "./variables";

// Import Google Cloud Providers
import { GoogleProvider } from "@cdktf/provider-google/lib/provider";
// @ts-ignore
import * as fs from 'fs';
// @ts-ignore
import * as path from 'path';

// Add this import
import { CloudRunModule } from "./modules/cloudRun";
// Add this new import
import { ArtifactRegistryModule } from "./modules/artifactRegistry";

class MyStack extends TerraformStack {
  constructor(scope: Construct, name: string) {
    super(scope, name);

    const vars = new Variables(this, "variables");

    new GoogleProvider(this, "google", {
      project: vars.project_id.value,
      region: vars.region.value,
      zone: vars.zone.value,
    });

    // Update the ArtifactRegistryModule
    new ArtifactRegistryModule(this, "artifact-registry", {
      projectName: vars.project_name.value,
      region: vars.region.value,
    });

    // Update the CloudRunModule
    new CloudRunModule(this, "cloudrun", {
      projectName: vars.project_name.value,
      region: vars.region.value,
      projectId: vars.project_id.value,
    });
  }
}

const app = new App();
new MyStack(app, "learn-cdktf-docker");
app.synth();
