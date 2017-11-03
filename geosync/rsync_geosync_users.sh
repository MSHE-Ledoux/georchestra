#!/bin/bash

rsync --delete -av --exclude .viminfo --exclude .bash_history /home/georchestra-ouvert    /home/georchestra/georchestra/geosync/
rsync --delete -av --exclude .viminfo --exclude .bash_history /home/georchestra-restreint /home/georchestra/georchestra/geosync/

