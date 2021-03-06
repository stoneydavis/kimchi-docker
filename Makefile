build:
	@docker build -t blade2005/kimchi .
pull:
	@docker pull blade2005/kimchi
run:
	@docker run -P --name kimchi -d blade2005/kimchi
