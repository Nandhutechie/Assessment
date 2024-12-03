package com.novosoft.ProductAssessment.TaskScheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.novosoft.ProductAssessment.service.FetchAndUpdateService;
import com.novosoft.ProductAssessment.service.ProductService;

@Component
public class ProductPriceUpdater {

	    private final FetchAndUpdateService productFetchUpdateService;

	    public ProductPriceUpdater(FetchAndUpdateService productFetchUpdateService) {
	        this.productFetchUpdateService = productFetchUpdateService;
	    }

	   // @Scheduled(cron = "0 0 0 * * ?") // Runs every 24 hours
	    @Scheduled(cron = "0 0/5 * * * ?")
	    public void updatePrices() {
	    	productFetchUpdateService.updateProductPrices();
	    }
	}