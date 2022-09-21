import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: "10s",
  rps: 5,
};

const hostname = "https://nmqv3-stress-test-ingress.91dev.tw";

export default function() {
  const url = `${hostname}/api/v1/tasks`;

  const payload = {
    "jobName": "Heartbeat",
  }

  let resp = http.post(url, JSON.stringify(payload), {
    headers: { 'Content-Type': 'application/json' }
  });

  check(resp, { "status = 200": resp.status === 200 })
  console.log(GenerateGuid());
  sleep(1);
}
