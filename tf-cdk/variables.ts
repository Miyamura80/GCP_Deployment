import { TerraformVariable } from "cdktf";
import { Construct } from "constructs";

export class Variables extends Construct {
  [key: string]: TerraformVariable | any;

  constructor(scope: Construct, name: string) {
    super(scope, name);

    const vars: Record<string, [string, string]> = {
      region: ["The region where resources will be created", "europe-west2"],
      zone: ["The zone where resources will be created", "europe-west2-b"],
      project_id: ["The project ID", "superb-memory-392811"],
      project_name: ["The project name", "my-server"],
    };

    Object.entries(vars).forEach(([key, [description, defaultValue]]) => {
      this[key] = this.createVariable(key, description, defaultValue);
    });
  }

  private createVariable(name: string, description: string, defaultValue: string): TerraformVariable {
    return new TerraformVariable(this, name, {
      type: "string",
      description,
      default: process.env[`TF_VAR_${name.toUpperCase()}`] || defaultValue,
    });
  }
}
