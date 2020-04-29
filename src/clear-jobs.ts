import config from "./config";
import { request } from "https";
import { IncomingWebhook } from "@slack/webhook";

const jwtStrategy = require("login.dfe.jwt-strategies");

// generate token
async function getToken(): Promise<string> {
  return await jwtStrategy(config.token).getBearerToken();
}

function makeRequest(token: string, body: string): Promise<any> {
  const DATA = JSON.stringify({
    state: body
  });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: config.endpoint,
      port: 443,
      path: "/monitor",
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": DATA.length,
        Authorization: `Bearer ${token}`
      }
    };

    const req = request(options, res => {
      if (res.statusCode === 200 || res.statusCode === 304) {
        resolve(res);
      } else {
        reject(res);
      }
    });

    req.on("error", error => {
      reject(error);
    });

    req.write(DATA);
    req.end();
  });
}

function sleep(ms: number = 10000): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function notify(title: string, msg: string): Promise<void> {
  return new Promise(async (resolve, reject) => {
    const webhook = new IncomingWebhook("");

    let a = await webhook.send({
      attachments: [
        {
          fallback: "Clear jobs ran",
          color: "#36a64f",
          author_name: "dfe.login.infrastructure",
          title: title,
          text: msg,
          footer: "Archronos",
          footer_icon:
            "http://archronos.com/wp-content/uploads/2019/02/square-1.png",
          ts: `${Date.now()}`
        }
      ]
    });

    console.log(a);

    resolve();
  });
}

(async function run(): Promise<void> {
  let errorCode;
  try {
    let token = await getToken();
    await makeRequest(token, "stopped");
    // await notify("Jobs stopped", "KueJS jobs stopped");
    await sleep(config.wait);
    await makeRequest(token, "started");
    await notify("Jobs started", "KueJS jobs started");
  } catch (e) {
    console.error(e);
    errorCode = 1;
  } finally {
    process.exit(errorCode);
  }
})();
