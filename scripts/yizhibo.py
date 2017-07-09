#!/usr/bin/env python2
#coding: utf-8

from gevent import monkey
monkey.patch_all()
from gevent.pool import Pool
import gevent
import requests
import urlparse
import os
import sys
import time
import json

proxies = {'http': None, 'https': None}
headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}

class Downloader:
    def __init__(self, pool_size, retry=3):
        self.proxies = proxies
        self.headers = headers
        self.pool = Pool(pool_size)
        self.session = self._get_http_session(pool_size, pool_size, retry)
        self.retry = retry
        self.dir = ''
        self.succed = {}
        self.failed = []
        self.ts_total = 0

    def _get_http_session(self, pool_connections, pool_maxsize, max_retries):
        session = requests.Session()
        session.proxies = self.proxies
        session.headers = self.headers
        adapter = requests.adapters.HTTPAdapter(pool_connections=pool_connections, pool_maxsize=pool_maxsize, max_retries=max_retries)
        session.mount('http://', adapter)
        session.mount('https://', adapter)
        return session

    def run(self, m3u8_url, dir='', output_name='output.ts'):
        self.output_name = output_name
        self.dir = dir
        if self.dir and not os.path.isdir(self.dir):
            os.makedirs(self.dir)

        r = self.session.get(m3u8_url, timeout=10, proxies=self.proxies)
        if r.ok:
            body = r.content
            if body:
                ts_list = [urlparse.urljoin(m3u8_url, n.strip()) for n in body.split('\n') if n and not n.startswith("#")]
                ts_list = zip(ts_list, [n for n in xrange(len(ts_list))])
                if ts_list:
                    self.ts_total = len(ts_list)
                    print(self.ts_total)
                    g1 = gevent.spawn(self._join_file)
                    self._download(ts_list)
                    g1.join()
        else:
            print(r.status_code)

    def _download(self, ts_list):
        self.pool.map(self._worker, ts_list)
        if self.failed:
            ts_list = self.failed
            self.failed = []
            self._download(ts_list)

    def _worker(self, ts_tuple):
        url = ts_tuple[0]
        index = ts_tuple[1]
        retry = self.retry
        while retry:
            try:
                r = self.session.get(url, timeout=20, proxies=self.proxies)
                if r.ok:
                    file_name = url.split('/')[-1]
                    print(file_name)
                    with open(os.path.join(self.dir, file_name), 'wb') as f:
                        f.write(r.content)
                    self.succed[index] = file_name
                    return
            except:
                retry -= 1
        print('[FAIL]%s' % url)
        self.failed.append((url, index))

    def _join_file(self):
        index = 0
        outfile = ''
        while index < self.ts_total:
            file_name = self.succed.get(index, '')
            if file_name:
                infile = open(os.path.join(self.dir, file_name), 'rb')
                if not outfile:
                    outfile = open(os.path.join(self.dir, file_name.split('.')[0]+'_all.'+file_name.split('.')[-1]), 'wb')
                outfile.write(infile.read())
                infile.close()
                os.remove(os.path.join(self.dir, file_name))
                index += 1
            else:
                time.sleep(1)
        if outfile:
            outfile.close()
        os.rename(outfile.name, self.output_name)

if __name__ == '__main__':
    args = sys.argv[1:]
    for i in args:
        u = i.split('/')[-1].split(".html")[0]
        url = 'http://www.yizhibo.com/live/h5api/get_basic_live_info?scid={}'.format(u)
        print(url)
        js = requests.get(url, proxies=proxies, headers=headers).json()
        # ret = ret.decode('utf-8')
        # js = json.loads(ret)
        print(js['msg'].encode('utf-8'))
        nickname = js['data']['nickname']
        live_title = js['data']['live_title']
        starttime = time.strftime("%Y-%m-%d-%H%M", time.localtime(int(js['data']['starttime'])))
        file_name = '{} - {} - {}.ts'.format(nickname.encode('utf-8'), live_title.encode('utf-8'), starttime)
        print(file_name)
        play_url = js['data']['play_url']
        downloader = Downloader(50)
        downloader.run(play_url, os.getcwd(), output_name=file_name)
