package com.novosoft.ProductAssessment.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Entity
@Data
@Table(
	    name = "product",
	    indexes = {
	        @Index(name = "idx_product_name", columnList = "name"),
	        @Index(name = "idx_product_price", columnList = "price")
	    }
	)
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

   @NotBlank(message = "Name cannot be blank")
    private String name;

    private String description;

    @NotNull(message = "Price cannot be null")
    private Double price;

    
//    @Column(columnDefinition = "DATETIME")
//    private LocalDateTime createdDate;
//
//    @PrePersist
//    public void prePersist() {
//        this.createdDate = LocalDateTime.now();
//    }

    
    
    @Column(name = "created_date")
    private String createdDate;

  

	public Product(Long id, @NotBlank(message = "Name cannot be blank") String name,
			@NotNull(message = "Price cannot be null") Double price) {
		super();
		this.id = id;
		this.name = name;
		this.price = price;
	}

	@PrePersist
    public void prePersist() {
        this.createdDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

	public void setCreatedDate(String createdDate) {
		this.createdDate = createdDate;
	}




	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Double getPrice() {
		return price;
	}

	public void setPrice(Double price) {
		this.price = price;
	}

	

    
}
