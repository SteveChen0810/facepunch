

Future<void> consoleLog(String log)async{
  try{
    print(log);
  }catch(e){
    print(e);
  }
}