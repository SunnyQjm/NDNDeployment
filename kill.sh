#!/bin/bash
kill `ps -aux | grep nfd | grep -v grep | awk '{print $2}'`
kill `ps -aux | grep nlsr | grep -v grep | awk '{print $2}'`
