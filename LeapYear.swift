import Foundation

func isLeap(year: Int) -> Bool{
    if(year%400 == 0 || (year % 4 == 0 && year % 100 != 0)){
        return true
    }else{
        return false
    }
}

print(isLeap(year: 2000))
print(isLeap(year: 1209))
print(isLeap(year: 1980))
print(isLeap(year: 1790))
print(isLeap(year: 1993))
