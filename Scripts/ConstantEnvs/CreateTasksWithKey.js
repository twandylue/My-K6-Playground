import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  // discardResponseBodies: true,
  scenarios: {
    contacts: {
      executor: 'constant-arrival-rate',
      duration: `${__ENV.DURATION}`,
      rate: `${__ENV.RATE}`,
      preAllocatedVUs: `${__ENV.PREALLOCATEDVUS}`,
      maxVUs: `${__ENV.MAXVUS}`,
      timeUnit: '1s',
    },
  },
};

const hostname = "https://nmqv3-apimin.qa.91dev.tw";

export default function() {
  const url = `${hostname}/api/v1/tasks`;

  const payload = {
    "jobName": "Heartbeat",
    "idempotencyKey": GenerateGuid(),
  }

  let resp = http.post(url, JSON.stringify(payload), {
    headers: { 'Content-Type': 'application/json' }
  });

  check(resp, { "status = 200": resp.status === 200 })
  // sleep(1);
}

function GenerateGuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
