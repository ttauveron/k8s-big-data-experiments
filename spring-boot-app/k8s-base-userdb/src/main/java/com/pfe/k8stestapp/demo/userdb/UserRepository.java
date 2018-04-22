package com.pfe.k8stestapp.demo.userdb;

import org.springframework.data.repository.CrudRepository;

import com.pfe.k8stestapp.demo.userdb.User;

// This will be AUTO IMPLEMENTED by Spring into a Bean called userRepository
// CRUD refers Create, Read, Update, Delete

public interface UserRepository extends CrudRepository<User, Long> {

}