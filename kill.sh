#!/bin/bash
kill -9 `ps -aux | grep nfd | grep -v grep | awk '{print $2}'`
kill -9 `ps -aux | grep nlsr | grep -v grep | awk '{print $2}'`
