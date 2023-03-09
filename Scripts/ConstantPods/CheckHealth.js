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
// e.g. http://nmqv3-apimin.qa.91dev.tw/_hc
const hostname = "http://nmqv3-apimin.qa.91dev.tw";

export default function() {
  const url = `${hostname}/_hc`;

  let resp = http.get(url, {
    headers: { 'Content-Type': 'application/json' }
  });

  check(resp, { "status = 200": resp.status === 200 })
  // sleep(1);
}
