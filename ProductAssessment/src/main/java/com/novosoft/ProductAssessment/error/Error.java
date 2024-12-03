package com.novosoft.ProductAssessment.error;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Error {

	public Error(String string) {
		// TODO Auto-generated constructor stub
	}

	@JsonProperty("Message")
    private String message;
}