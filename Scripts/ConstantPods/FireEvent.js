import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
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

const hostname = "************************";

export default function() {
  const url = `${hostname}/api/v1/event/`;

  const key = GenerateGuid();

  const payload = {
    "eventName": "HeartEvent",
    "eventArgs": {},
    "source": "All",
    "idempotencyKey": key,
    "sourceType": 1,
    "sourceKey": "",
    "createdAt": Date.UTC
  }

  let resp = http.post(url, JSON.stringify(payload), {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer dGhpcyBpcyBhIGFwaSBzZXJ2aWNlIHRva2Vu'
    }
  });

  check(resp, { "status = 200": resp.status === 200 })
}

function GenerateGuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
