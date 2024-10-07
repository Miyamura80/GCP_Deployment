
deploy:
	cd tf-cdk && cdktf deploy && cd ..

destroy:
	cd tf-cdk && cdktf destroy && cd ..