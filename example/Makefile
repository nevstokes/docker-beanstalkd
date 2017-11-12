.DEFAULT_GOAL := help
.PHONY: help run

.env: .env.dist
	@cp $< $@

vendor: composer.lock
	@docker run --rm -t -v $(PWD):/var/www \
		nevstokes/composer:prestissimo \
		install \
			--classmap-authoritative \
			--ignore-platform-reqs \
			--prefer-dist \
			--no-progress \
			--no-scripts \
			--no-suggest

help: ## Display list and descriptions of available targets
	@awk -F ':|\#\#' '/^[^\t].+:.*\#\#/ {printf "\033[36m%-15s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST) | sort

run: docker-compose.yml .env vendor ## Run the Docker example
	@docker-compose up -d

cleanup: ## Remove containers, env file and vendor directory
	@docker-compose down -v
	@rm -rf .env vendor
