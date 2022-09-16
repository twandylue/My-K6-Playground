import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 1,
  duration: "2s"
};

const hostname = "https://nmqv3-apimin.qa.91dev.tw";

export default function() {
  const url = `${hostname}/api/v1/tasks`;

  const payload = {
    "jobName": "Heartbeat",
  }

  let resp = http.post(url, JSON.stringify(payload), {
    headers: { 'Content-Type': 'application/json' }
  });

  check(resp, { "status = 200": resp.status === 200 })
  // let resp = http.get("https://backoffice.qa.91dev.tw/_hc");
  sleep(1);
}
