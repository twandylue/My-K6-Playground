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

// TW-QA
// e.g. http://nmqv3-apimin.qa.91dev.tw/api/v1/tasks/6956412b-2e1c-4236-9d55-54110f9f54a5
const taskId = "6956412b-2e1c-4236-9d55-54110f9f54a5"
const hostname = "http://nmqv3-apimin.qa.91dev.tw";

export default function() {
  const url = `${hostname}/api/v1/tasks/${taskId}`;

  let resp = http.get(url, {
    headers: { 'Content-Type': 'application/json' }
  });

  check(resp, { "status = 200": resp.status === 200 })
  // sleep(1);
}
