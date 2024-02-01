import dns from "dns/promises";
import { createClient } from "redis";

const main = async () => {
  console.log("hi");
  console.log("Hello World");
  console.log("Hello World 2");

  const client = createClient({
    url: "redis://redis-master",
  });

  client.on("error", (err) => console.log("Redis Client Error", err));

  await client.connect();

  const result = await dns.lookup("redis-headless", 4);
  console.log({ result });

  const address = await client.get(result.address);
  console.log({ address });
  if (!address) {
    await client.set(result.address, 1);
  }
};

main();
