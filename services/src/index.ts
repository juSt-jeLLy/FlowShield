import { config } from "./config";
import { Storage } from "./storage";
import { Metrics } from "./metrics";
import { startIndexer } from "./indexer";
import { createApi } from "./api";

const storage = new Storage();
const metrics = new Metrics();

async function main() {
  const app = createApi(storage, metrics);

  app.listen(config.port, () => {
    console.log(`FlowShield services listening on http://localhost:${config.port}`);
  });

  await startIndexer(storage, metrics);
}

main().catch((error) => {
  console.error("[services] fatal error", error);
  process.exit(1);
});
