import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  // discardResponseBodies: true,
  scenarios: {
    contacts: {
      executor: 'constant-arrival-rate',

      // Our test should last 30 seconds in total
      duration: '30s',

      // It should start 30 iterations per `timeUnit`. Note that iterations starting points
      // will be evenly spread across the `timeUnit` period.
      rate: 30,

      // It should start `rate` iterations per second
      timeUnit: '1s',

      // It should preallocate 2 VUs before starting the test
      preAllocatedVUs: 2,

      // It is allowed to spin up to 50 maximum VUs to sustain the defined
      // constant arrival rate.
      maxVUs: 50,
    },
  },
};

const hostname = "https://nmqv3-stress-test-ingress.91dev.tw";

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
  // console.log(GenerateGuid());
  // sleep(1);
}

function GenerateGuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
