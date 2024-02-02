import { AppsV1Api, KubeConfig } from "@kubernetes/client-node";

const kc = new KubeConfig();
kc.loadFromDefault();
const k8sApi = kc.makeApiClient(AppsV1Api);

const deploymentName = "euclid";
const namespace = "default"; // change if your deployment is in a different namespace
let currentReplicas = 2;

async function updateReplicas() {
  currentReplicas = currentReplicas >= 8 ? 2 : currentReplicas + 1;
  try {
    await k8sApi.patchNamespacedDeploymentScale(
      deploymentName,
      namespace,
      { spec: { replicas: currentReplicas } },
      undefined,
      undefined,
      undefined,
      undefined,
      undefined,
      { headers: { "Content-Type": "application/strategic-merge-patch+json" } }
    );
    console.log(`Updated replicas to: ${currentReplicas}`);
  } catch (err) {
    console.error("Error updating replicas:", (err as any).body);
  }
}

setInterval(updateReplicas, 30000);
