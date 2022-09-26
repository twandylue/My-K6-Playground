import http from 'k6/http';
import { check, sleep } from 'k6';
import exec from 'k6/execution';

export const options = {
  // discardResponseBodies: true,
  scenarios: {
    contacts: {
      executor: 'constant-arrival-rate',
      duration: "10s",
      rate: 30,
      preAllocatedVUs: 30,
      maxVUs: 50,
      timeUnit: '1s',
    },
  },
};

const baseUrl = "https://memberservice-api-internal.qa.91dev.tw";

export default function() {
  const url = `${baseUrl}/api/members`;

  let data = new Data();
  // if (data.UniqueInt() > 100) exec.test.abort();

  let resp = http.post(url, JSON.stringify(new Data()), {
    headers: {
      'Content-Type': 'application/json',
      'ny-market': 'TW',
      'ny-shop-id': '91',
      'ny-user-id': '@@TestUser@@',
      'ny-service-cert': 'xyz',
    }
  });

  check(resp, { "status = 200": resp.status === 200 })
  // sleep(1);
}

const MAX = 1000000000;

class Bundle {
  constructor(id) {
    this.id = id
    this.extensions = {
      "uczq": "Water Supply"
    };
    this.sourceCreatedBy = "VerdaHietala";
    this.sourceCreatedAt = "1977-11-24T00:00:00+08:00";
  }
}

class Profile {
  constructor() {
    this.name = {
      "firstName": "Angel",
      "lastName": "Eskew",
      "fullName": "SabraPagliarini"
    };
    this.gender = "Female";
    this.birthday = {
      "year": 1999,
      "month": 5,
      "day": 2
    };
    this.eComJoinDateTime = "1997-02-20T06:28:09.2912278+08:00";
    this.migrateJoinDateTime = "1971-04-22T20:10:02.78445+08:00";
    this.contactEmail = "andylu@gmail.com";
    this.locale = "Yugoslavia";
    this.address = {
      "postalCode": "A1J6A7",
      "country": "Ghana",
      "province": "Saskatchewan",
      "city": "Reed",
      "district": "Vermont ",
      "address1": "Lindsey Lane",
      "address2": "test 123"
    };
    this.identityCardId = "-96";
    this.education = "German";
    this.annualIncome = "826333";
    this.custom1 = "Custom1-100000";
    this.custom2 = "Custom2-100000";
    this.custom3 = "Custom3-100000";
    this.custom4 = "Custom4-100000";
    this.custom5 = "Custom5-100000";
  }
}

class Data {
  constructor() {
    this.Bundles = [];
    this.Bundles.push(new Bundle(`Phone#${this.RandomPhoneNumber()}`));
    this.Bundles.push(new Bundle(`Email#${this.RandomEmail()}`));
    this.Bundles.push(new Bundle(`ShopThirdParty#${this.RandomInt()}`));
    this.Bundles.push(new Bundle(`Google#${this.RandomInt()}`));
    this.Bundles.push(new Bundle(`FB#${this.RandomInt()}`));
    this.Bundles.push(new Bundle(`Apple#${this.RandomInt()}`));
    this.Bundles.push(new Bundle(`Line#${this.RandomInt()}`));
    this.Bundles.push(new Bundle(`MemberId#${this.RandomInt()}`));
    this.Bundles.push(new Bundle(`VipMemberId#${this.RandomInt()}`));
    this.Bundles.push(new Bundle(`CrmMemberId#${this.RandomInt()}`));
    this.Profile = new Profile();
  }

  RandomPhoneNumber() {
    return "+8860" + this.UniqueInt();
  }

  UniqueInt() {
    return exec.scenario.iterationInTest;
  }

  RandomInt() {
    return Math.floor(Math.random() * (MAX) + 1);
  }

  RandomEmail() {
    return this.GenerateGuid().replace(/-/g, '') + "@" + "91app.com.tw";
  }

  GenerateGuid() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}
