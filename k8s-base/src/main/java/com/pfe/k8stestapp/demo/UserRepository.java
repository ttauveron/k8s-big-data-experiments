package com.pfe.k8stestapp.demo;

import org.springframework.data.repository.CrudRepository;

import com.pfe.k8stestapp.demo.User;

// This will be AUTO IMPLEMENTED by Spring into a Bean called userRepository
// CRUD refers Create, Read, Update, Delete

public interface UserRepository extends CrudRepository<User, Long> {

}