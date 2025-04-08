import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 1000,
  duration: '90s',
};

export default function() {
  for (let id = 1; id <= 16; id++) {
    http.get(`http://FCJ-Management-LB-2047831794.ap-southeast-1.elb.amazonaws.com/${id}`);
    sleep(1);
  }
}
