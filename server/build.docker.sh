#!/bin/bash

cp -r ../client/supabase ./supabase
docker build -t dropin:latest . 