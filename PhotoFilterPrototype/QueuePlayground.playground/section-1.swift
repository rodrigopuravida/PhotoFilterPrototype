//Playground - noun: a place where people can play

import UIKit

//QUEUE

class Car {
  var model = "Test"
  
  
  var myParkingLot = [Car]()
  var firstOriginalCar : Car!
  
  func enqueue(car : Car) {
    if !self.myParkingLot.isEmpty {
      self.myParkingLot.append(car)
    }
  }
  
  func deQueue() -> Car? {
    if !self.myParkingLot.isEmpty{
      let item = self.myParkingLot.first
      self.myParkingLot.removeAtIndex(0)
      return item!
    } else {
      return nil
    }
  }
  
  
  func peek() -> Car {
    return self.myParkingLot.first!
  }
  
}

//TEST SECTION

var sporty =  Car()
sporty.model = "Porsche"
var clunker = Car()
clunker.model = "Yugo"
var truck = Car()
truck.model = "Ford 150"
var foreign = Car()
foreign.model = "BMW"

clunker.myParkingLot.append(sporty)
clunker.myParkingLot.append(clunker)

//COUnt should be 2
println(clunker.myParkingLot.count)

//Let's enque the truck and validate
//1. That Truck is last in line

clunker.enqueue(truck)
//This should be the F-150 as last car
println(clunker.myParkingLot.last?.model)
//Count should be 3
println(clunker.myParkingLot.count)
//Now lets deque which means the Porsche is gone and the car at index 0 woul be the clunker
clunker.deQueue()
//count should be 2
println(clunker.myParkingLot.count)
//Now let's check that first is Clunker = Yugo
println(clunker.myParkingLot.first?.model)
//Peek shoulg give same result - Yugo
println(clunker.myParkingLot.first?.model)
















