import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "timeSheetSystemForEmployee" : MessageLookupByLibrary.simpleMessage("SISTEMA DE GESTIÓN DEL TIEMPO DEL EMPLEADO"),
    "yourEmailIsRequired" : MessageLookupByLibrary.simpleMessage("Su correo electrónico es requerido"),
    "emailIsInvalid" : MessageLookupByLibrary.simpleMessage("Correo electrónico invalidó"),
    "passwordIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere contraseña"),
    "email" : MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "enterYourEmailAddress" : MessageLookupByLibrary.simpleMessage("Ingrese su correo electrónico"),
    "password" : MessageLookupByLibrary.simpleMessage("Contraseña"),
    "enterYourPassword" : MessageLookupByLibrary.simpleMessage("Ingrese su contraseña"),
    "passwordTooShort" : MessageLookupByLibrary.simpleMessage("Ingrese 8 caracteres como mínimo"),
    "rememberMe" : MessageLookupByLibrary.simpleMessage("Recuérdame"),
    "cannotLogin" : MessageLookupByLibrary.simpleMessage("Imposible de conectar"),
    "login" : MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
    "facePunch" : MessageLookupByLibrary.simpleMessage("Facepunch"),
    "weWillSendNewPasswordToYourEmail" : MessageLookupByLibrary.simpleMessage("Una nueva contraseña ha sido enviada por correo electrónico"),
    "done" : MessageLookupByLibrary.simpleMessage("Terminar"),
    "firstNameIsRequired" : MessageLookupByLibrary.simpleMessage("Su nombre es requerido"),
    "lastNameIsRequired" : MessageLookupByLibrary.simpleMessage("Su apellido es requerido"),
    "signUp" : MessageLookupByLibrary.simpleMessage("Inscribirse"),
    "firstName" : MessageLookupByLibrary.simpleMessage("Nombre"),
    "enterYourFirstName" : MessageLookupByLibrary.simpleMessage("Ponga su nombre"),
    "lastName" : MessageLookupByLibrary.simpleMessage("Apellido"),
    "enterYourLastName" : MessageLookupByLibrary.simpleMessage("Ponga su appellido"),
    "register" : MessageLookupByLibrary.simpleMessage("Registrar"),
    "companyNameIsRequired" : MessageLookupByLibrary.simpleMessage("El nombre de la empresa es obligatorio"),
    "companyAddressIsRequired" : MessageLookupByLibrary.simpleMessage("La dirección de la empresa es requerido"),
    "countryIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere un estado "),
    "stateIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere un país "),
    "cityIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere una ciudad"),
    "postalCodeIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere un código postal"),
    "pleaseEnterYourCompanyInformation" : MessageLookupByLibrary.simpleMessage("Ingrese las informaciones de la empresa"),
    "companyName" : MessageLookupByLibrary.simpleMessage("Nombre de empresa"),
    "streetAddress" : MessageLookupByLibrary.simpleMessage("Dirección"),
    "aptSuiteBuilding" : MessageLookupByLibrary.simpleMessage("Dirección 2"),
    "postalCode" : MessageLookupByLibrary.simpleMessage("Código postal"),
    "phoneNumber" : MessageLookupByLibrary.simpleMessage("Número de teléfono"),
    "website" : MessageLookupByLibrary.simpleMessage("Sitio web"),
    "employees" : MessageLookupByLibrary.simpleMessage("Empleados"),
    "close" : MessageLookupByLibrary.simpleMessage("Cerrar"),
    "allowFacePunchToTakePictures" : MessageLookupByLibrary.simpleMessage("Permitir que el dispositivo use la cámara"),
    "thereIsNotAnyFaces" : MessageLookupByLibrary.simpleMessage("No se pudo detectar él visaje"),
    "locationPermissionDenied" : MessageLookupByLibrary.simpleMessage("Lokaj permesoj estas konstante malakceptitaj, ni ne povas peti permesojn."),
    "pinCodeNotCorrect" : MessageLookupByLibrary.simpleMessage("Código NIP invalido"),
    "welcome" : MessageLookupByLibrary.simpleMessage("Bienvenido"),
    "bye" : MessageLookupByLibrary.simpleMessage("Adiós"),
    "takePicture" : MessageLookupByLibrary.simpleMessage("Tomar una fotografía"),
    "tryAgain" : MessageLookupByLibrary.simpleMessage("Inténtalo de nuevo"),
    "startFacePunch" : MessageLookupByLibrary.simpleMessage("Comenzar FACEPUNCH"),
    "addContainers" : MessageLookupByLibrary.simpleMessage("No se encontró ningún contenedor, agregue un contenedor."),
    "addFields" : MessageLookupByLibrary.simpleMessage("No se encontraron campos, agregue un campo."),
    "createNewTask" : MessageLookupByLibrary.simpleMessage("Crear una nueva tarea"),
    "updateTask" : MessageLookupByLibrary.simpleMessage("Actualizar tarea"),
    "field" : MessageLookupByLibrary.simpleMessage("Campo"),
    "container" : MessageLookupByLibrary.simpleMessage("Cajas"),
    "save" : MessageLookupByLibrary.simpleMessage("Registrar"),
    "deleteTaskConfirm" : MessageLookupByLibrary.simpleMessage("¿Está seguro de que desea eliminar esta tarea?"),
    "delete" : MessageLookupByLibrary.simpleMessage("Cancelar"),
    "harvestTracking" : MessageLookupByLibrary.simpleMessage("Monitoreo de las cosechas"),
    "editContainer" : MessageLookupByLibrary.simpleMessage("Modificar las cajas"),
    "employee" : MessageLookupByLibrary.simpleMessage("Empleado"),
    "quantity" : MessageLookupByLibrary.simpleMessage("Cantidades"),
    "createNewField" : MessageLookupByLibrary.simpleMessage("Agregar un nuevo campo"),
    "updateField" : MessageLookupByLibrary.simpleMessage("Actualizar los campos"),
    "fieldName" : MessageLookupByLibrary.simpleMessage("Nombre del campo"),
    "fieldCrop" : MessageLookupByLibrary.simpleMessage("Cultura"),
    "fieldCropVariety" : MessageLookupByLibrary.simpleMessage("Variedad de la cultura"),
    "nameIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere un nombre"),
    "cropIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere una cultura"),
    "fieldNameIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere el nombre del campo"),
    "varietyIsRequired" : MessageLookupByLibrary.simpleMessage("Se requiere una variedad"),
    "deleteFieldConfirm" : MessageLookupByLibrary.simpleMessage("Esta seguro que desea eliminar este campo ?"),
    "createNewContainer" : MessageLookupByLibrary.simpleMessage("Crear una nueva caja"),
    "updateContainer" : MessageLookupByLibrary.simpleMessage("Actualizar un contenedor"),
    "containerName" : MessageLookupByLibrary.simpleMessage("Nombre de la caja"),
    "deleteContainerConfirm" : MessageLookupByLibrary.simpleMessage("Esta seguro que desea eliminar esta caja?"),
    "chooseColor" : MessageLookupByLibrary.simpleMessage("Elije un color"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "lowValueIsEmpty" : MessageLookupByLibrary.simpleMessage("Valor bajo está vacío."),
    "lowValueShouldBeNumber" : MessageLookupByLibrary.simpleMessage("El valor bajo debe ser un número"),
    "highValueIsEmpty" : MessageLookupByLibrary.simpleMessage("El valor alto está vacío"),
    "highValueShouldBeNumber" : MessageLookupByLibrary.simpleMessage("El valor alto debe ser un número"),
    "highValueShouldBeBigger" : MessageLookupByLibrary.simpleMessage("El valor alto debe ser mayor que el valor bajo"),
    "nfcSettings" : MessageLookupByLibrary.simpleMessage("Configuración NFC"),
    "fields" : MessageLookupByLibrary.simpleMessage("Campos"),
    "editField" : MessageLookupByLibrary.simpleMessage("Editar campo"),
    "containers" : MessageLookupByLibrary.simpleMessage("Cajas"),
    "deleteContainer" : MessageLookupByLibrary.simpleMessage("Eliminar contenedor"),
    "containerHour" : MessageLookupByLibrary.simpleMessage("Cajas / horas"),
    "highDefault" : MessageLookupByLibrary.simpleMessage("Alto (Por defecto: 3+)"),
    "mediumDefault" : MessageLookupByLibrary.simpleMessage("Mediano (Por defecto: 2.5+)"),
    "lowDefault" : MessageLookupByLibrary.simpleMessage("Bajo (Por defecto: 2.5-)"),
    "reportTime" : MessageLookupByLibrary.simpleMessage("Informe de horas trabajadas"),
    "lastUpdated" : MessageLookupByLibrary.simpleMessage("Última actualización"),
    "aboutApp" : MessageLookupByLibrary.simpleMessage("Sobre la aplicación"),
    "profile" : MessageLookupByLibrary.simpleMessage("Perfil"),
    "oldPassword" : MessageLookupByLibrary.simpleMessage("Antigua contraseña"),
    "newPassword" : MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
    "company" : MessageLookupByLibrary.simpleMessage("Empresa"),
    "receiveRevisionNotification" : MessageLookupByLibrary.simpleMessage("Notificación de revisión recibida"),
    "receivePunchNotification" : MessageLookupByLibrary.simpleMessage("Notificación de PUNCH recibida"),
    "notifications" : MessageLookupByLibrary.simpleMessage("Notificaciónes"),
    "editEmployee" : MessageLookupByLibrary.simpleMessage("Modificar la ficha de empleado"),
    "deleteEmployee" : MessageLookupByLibrary.simpleMessage("Eliminar la ficha de empleado"),
    "deleteEmployeeConfirm" : MessageLookupByLibrary.simpleMessage("¿Está seguro de que desea eliminar este registro de empleado?"),
    "inOut" : MessageLookupByLibrary.simpleMessage("Entrada/Salida"),
    "employeeLogIn" : MessageLookupByLibrary.simpleMessage("Inicio de sesión de empleado"),
    "empty" : MessageLookupByLibrary.simpleMessage("Vacía"),
    "employeeLogOut" : MessageLookupByLibrary.simpleMessage("Cierre de sesión de empleado"),
    "createNewEmployee" : MessageLookupByLibrary.simpleMessage("Crear un nuevo expediente de empleado"),
    "photoCropper" : MessageLookupByLibrary.simpleMessage("Cortar foto"),
    "success" : MessageLookupByLibrary.simpleMessage("¡Éxito!"),
    "camera" : MessageLookupByLibrary.simpleMessage("Cámara"),
    "gallery" : MessageLookupByLibrary.simpleMessage("Galería"),
    "passwordPin" : MessageLookupByLibrary.simpleMessage("Contraseña (NIP)"),
    "address" : MessageLookupByLibrary.simpleMessage("Dirección"),
    "employeeFunction" : MessageLookupByLibrary.simpleMessage("Función del empleado"),
    "startDate" : MessageLookupByLibrary.simpleMessage("Fecha de inicio"),
    "salary" : MessageLookupByLibrary.simpleMessage("Salario"),
    "birthday" : MessageLookupByLibrary.simpleMessage("Fecha de nacimiento"),
    "chooseLanguage" : MessageLookupByLibrary.simpleMessage("Elige un idioma"),
    "hasLunchBreak" : MessageLookupByLibrary.simpleMessage("Pausa de 30 minutos"),
    "edit" : MessageLookupByLibrary.simpleMessage("Editar"),
    "editEmployeePunch" : MessageLookupByLibrary.simpleMessage("Editar la hoja de horas de un empleado"),
    "correctLunchTime" : MessageLookupByLibrary.simpleMessage("Editar la pausa de un empleado"),
    "incorrectLunchTime" : MessageLookupByLibrary.simpleMessage("Pausa de la cena incorrecta"),
    "correctPunchTime" : MessageLookupByLibrary.simpleMessage("Editar la hoja de horas de un empleado"),
    "incorrectPunchTime" : MessageLookupByLibrary.simpleMessage("Hoja de tiempo incorrecta"),
    "dailyLogs" : MessageLookupByLibrary.simpleMessage("Registro diario"),
    "totalHours" : MessageLookupByLibrary.simpleMessage("Horas totales"),
    "timeSheet" : MessageLookupByLibrary.simpleMessage("Hoja de tiempo"),
    "in" : MessageLookupByLibrary.simpleMessage("Entrada"),
    "out" : MessageLookupByLibrary.simpleMessage("Salida"),
    "pdfNotGenerated" : MessageLookupByLibrary.simpleMessage("El archivo aún no ha sido generado"),
    "harvestReportNotGenerated" : MessageLookupByLibrary.simpleMessage("El Informe de Cosecha aún no ha sido generado"),
    "calender" : MessageLookupByLibrary.simpleMessage("Calendario"),
    "document" : MessageLookupByLibrary.simpleMessage("Documento"),
    "setting" : MessageLookupByLibrary.simpleMessage("Configuraciones"),
    "faceScanLogin" : MessageLookupByLibrary.simpleMessage("Conexión FACESCAN"),
    "language" : MessageLookupByLibrary.simpleMessage("Idioma"),
    "country" : MessageLookupByLibrary.simpleMessage("Estado"),
    "state" : MessageLookupByLibrary.simpleMessage("País"),
    "city" : MessageLookupByLibrary.simpleMessage("Ciudad"),
    "lunchBreakFrom" : MessageLookupByLibrary.simpleMessage("Inicio de la pausa para la cena"),
    "to" : MessageLookupByLibrary.simpleMessage("De"),
    "punch" : MessageLookupByLibrary.simpleMessage("Punch"),
    "at" : MessageLookupByLibrary.simpleMessage("A"),
    "total" : MessageLookupByLibrary.simpleMessage("Total"),
    "hours" : MessageLookupByLibrary.simpleMessage("Horas"),
    "hoursForLunch" : MessageLookupByLibrary.simpleMessage("Horas de pausa"),
    "hourRevisionRequest" : MessageLookupByLibrary.simpleMessage("Solicitar una revisión de horas"),
    "submit" : MessageLookupByLibrary.simpleMessage("Enviar"),
    "week" : MessageLookupByLibrary.simpleMessage("Semana"),
    "time" : MessageLookupByLibrary.simpleMessage("Horas"),
    "noPunch" : MessageLookupByLibrary.simpleMessage("No hay información"),
    "logs" : MessageLookupByLibrary.simpleMessage("Periódico"),
    "askRevision" : MessageLookupByLibrary.simpleMessage("Para solicitar una revisión, seleccione la línea en error"),
    "enterPinCode" : MessageLookupByLibrary.simpleMessage("Ingrese su código NIP"),
    "employeeName" : MessageLookupByLibrary.simpleMessage("Nombre del empleado"),
    "accept" : MessageLookupByLibrary.simpleMessage("Aceptar"),
    "decline" : MessageLookupByLibrary.simpleMessage("Declinar"),
    "punchIn" : MessageLookupByLibrary.simpleMessage("Entrada"),
    "punchOut" : MessageLookupByLibrary.simpleMessage("Salida"),
    "pin" : MessageLookupByLibrary.simpleMessage("Código NIP"),
    "harvestReport" : MessageLookupByLibrary.simpleMessage("Informe de cosechas"),
    "totalOfTheDay" : MessageLookupByLibrary.simpleMessage("Total del día"),
    "totalOfTheSeason" : MessageLookupByLibrary.simpleMessage("Total de la temporada"),
    "nfc" : MessageLookupByLibrary.simpleMessage("NFC"),
    "searchEmployee" : MessageLookupByLibrary.simpleMessage("Buscar un empleado"),
    "selectProject" : MessageLookupByLibrary.simpleMessage("Seleccione un proyecto"),
    "selectTask" : MessageLookupByLibrary.simpleMessage("Selecciona una tarea"),
    "youAreWorkingOn" : MessageLookupByLibrary.simpleMessage("Actualmente estás trabajando en"),
    "youAreWorkingOnCall" : MessageLookupByLibrary.simpleMessage("Estás trabajando en una LLAMADA"),
    "project" : MessageLookupByLibrary.simpleMessage("Proyecto"),
    "activity" : MessageLookupByLibrary.simpleMessage("Actividad"),
    "startTime" : MessageLookupByLibrary.simpleMessage("Tiempo de empeza"),
    "endTime" : MessageLookupByLibrary.simpleMessage("Tiempo de salida"),
    "dailySchedule" : MessageLookupByLibrary.simpleMessage("Horario periódico"),
    "editWorkHistory" : MessageLookupByLibrary.simpleMessage("Modificar el histórico de trabajo"),
    "start" : MessageLookupByLibrary.simpleMessage("Empezar"),
    "resume" : MessageLookupByLibrary.simpleMessage("Regreso"),
    "end" : MessageLookupByLibrary.simpleMessage("Final"),
    "pressToStart" : MessageLookupByLibrary.simpleMessage("Presiona para empezar"),
    "pressToEnd" : MessageLookupByLibrary.simpleMessage("Presiona para terminar"),
    "pressToAskRevision" : MessageLookupByLibrary.simpleMessage("Presiona para solicitar una revisión"),
    "scheduleRevision" : MessageLookupByLibrary.simpleMessage("Revisión del horario"),
    "todo" : MessageLookupByLibrary.simpleMessage("Por hacer"),
    "notes" : MessageLookupByLibrary.simpleMessage("Notas"),
    "dispatch" : MessageLookupByLibrary.simpleMessage("Dispatch"),
    "addSchedule" : MessageLookupByLibrary.simpleMessage("Ingrese un horario"),
    "type" : MessageLookupByLibrary.simpleMessage("Tipo"),
    "priority" : MessageLookupByLibrary.simpleMessage("Prioridad"),
    "call" : MessageLookupByLibrary.simpleMessage("Llamada"),
    "shop" : MessageLookupByLibrary.simpleMessage("Tienda"),
    "schedule" : MessageLookupByLibrary.simpleMessage("Horario"),
    "selectCall" : MessageLookupByLibrary.simpleMessage("Seleccione una LLAMADA"),
    "startCall" : MessageLookupByLibrary.simpleMessage("Iniciar una LLAMADA"),
    "task" : MessageLookupByLibrary.simpleMessage("Tareas"),
    "note" : MessageLookupByLibrary.simpleMessage("Notas"),
    "selectSchedule" : MessageLookupByLibrary.simpleMessage("Seleccionar horario"),
    "shift" : MessageLookupByLibrary.simpleMessage("Tiempo de trabajo"),
    "startSchedule" : MessageLookupByLibrary.simpleMessage("Iniciar un horario"),
    "description" : MessageLookupByLibrary.simpleMessage("Descripción"),
    "youMustWriteDescription" : MessageLookupByLibrary.simpleMessage("Ingresa una descripción"),
    "startWorking" : MessageLookupByLibrary.simpleMessage("Iniciar el trabajo"),
    "breaks" : MessageLookupByLibrary.simpleMessage("Pausa"),
    "incorrectBreakTime" : MessageLookupByLibrary.simpleMessage("Hora de pausa incorrecta"),
    "correctBreakTime" : MessageLookupByLibrary.simpleMessage("Hora de pausa correcta"),
    "length" : MessageLookupByLibrary.simpleMessage("Duración"),
    "breakLengthCanNotBeZero" : MessageLookupByLibrary.simpleMessage("La duración de la pausa no puede ser igual a 0"),
    "invalidBreakLength" : MessageLookupByLibrary.simpleMessage("Duración de la pausa no válida"),
    "dailyTasks" : MessageLookupByLibrary.simpleMessage("Tareas diarias"),
    "schedules" : MessageLookupByLibrary.simpleMessage("Horario"),
    "calls" : MessageLookupByLibrary.simpleMessage("Llamada"),
    "incorrect" : MessageLookupByLibrary.simpleMessage("Incorrecta"),
    "correct" : MessageLookupByLibrary.simpleMessage("Correcta"),
    "selectPriority" : MessageLookupByLibrary.simpleMessage("Elektu Prioritaton"),
    "deletePunchConfirm" : MessageLookupByLibrary.simpleMessage("¿Está seguro de que desea eliminar este PUNCH?"),
    "deleteWorkConfirm" : MessageLookupByLibrary.simpleMessage("¿Está seguro de que desea eliminar este trabajo?"),
    "deleteBreakConfirm" : MessageLookupByLibrary.simpleMessage("¿Está seguro de que desea eliminar esta pausa?"),
    "breakTime" : MessageLookupByLibrary.simpleMessage("Tiempo de pausa"),
    "newVersionAvailable" : MessageLookupByLibrary.simpleMessage("Ya está disponible una nueva versión. ¿Te gustaría actualizar a la nueva versión?"),
    "update" : MessageLookupByLibrary.simpleMessage("Actualizar"),
    "callRevision" : MessageLookupByLibrary.simpleMessage("Revisión de la llamadas"),
    "addCall" : MessageLookupByLibrary.simpleMessage("Agregar llamada"),
    "bugReport" : MessageLookupByLibrary.simpleMessage("Informe de errores"),
    "make" : MessageLookupByLibrary.simpleMessage("Make"),
    "model" : MessageLookupByLibrary.simpleMessage("Modelo"),
    "os" : MessageLookupByLibrary.simpleMessage("SO (Sistema de operación)"),
    "version" : MessageLookupByLibrary.simpleMessage("Versión"),
    "brand" : MessageLookupByLibrary.simpleMessage("Marca"),
    "name" : MessageLookupByLibrary.simpleMessage("Nombre"),
    "system" : MessageLookupByLibrary.simpleMessage("Sistema"),
    "bugReportDescription" : MessageLookupByLibrary.simpleMessage("Incluya una descripción de sus errores aquí…"),
    "punchTime" : MessageLookupByLibrary.simpleMessage("Horario de PUNCH"),
    "revisionHasBeenSent" : MessageLookupByLibrary.simpleMessage("Una solicitud de revisión ha sido enviada"),
    "sent" : MessageLookupByLibrary.simpleMessage("Enviar"),
    "accepted" : MessageLookupByLibrary.simpleMessage("Aceptar"),
    "declined" : MessageLookupByLibrary.simpleMessage("Declinar"),
    "tapToSubmitDescription" : MessageLookupByLibrary.simpleMessage("Toca para enviar una descripción"),
    "invalidNFC" : MessageLookupByLibrary.simpleMessage("No se puede encontrar el NFC"),
    "notAllowedNFC" : MessageLookupByLibrary.simpleMessage("Permitir que el dispositivo use NFC"),
    "deleteHarvestConfirm" : MessageLookupByLibrary.simpleMessage("¿Está seguro de que desea eliminar este cultivo?"),
    "thankYouForReporting" : MessageLookupByLibrary.simpleMessage("Gracias por informar un error."),
    "open" : MessageLookupByLibrary.simpleMessage("Abrir"),
    "callDetail" : MessageLookupByLibrary.simpleMessage("Detalles de llamadas"),
    "date" : MessageLookupByLibrary.simpleMessage("Fecha"),
    "thisPunchHasBeenSentAlready" : MessageLookupByLibrary.simpleMessage("Este PUNCH ya ha sido enviado"),
    "canNotSendRevisionAfterStart" : MessageLookupByLibrary.simpleMessage("No se puede enviar la revisión después del inicio"),
    "canNotEditDeleteCall" : MessageLookupByLibrary.simpleMessage("No se puede modificar o eliminar una LLAMADA procesada"),
    "workingNow" : MessageLookupByLibrary.simpleMessage("Trabajando ahora"),
    "works" : MessageLookupByLibrary.simpleMessage("Trabajo"),
    "workRevision" : MessageLookupByLibrary.simpleMessage("Revisión del trabajo"),
    "revisions" : MessageLookupByLibrary.simpleMessage("Revisión"),
    "deviceIdForPunch" : MessageLookupByLibrary.simpleMessage("ID de dispositivo para PUNCH"),
    "clickToCopy" : MessageLookupByLibrary.simpleMessage("Pulsa para copiar"),
    "deviceIdCopied" : MessageLookupByLibrary.simpleMessage("ID de dispositivo copiado"),
    "startManualBreak" : MessageLookupByLibrary.simpleMessage("Iniciar la pausa manualmente"),
    "endManualBreak" : MessageLookupByLibrary.simpleMessage("Terminar el descanso manualmente"),
    "somethingWentWrong" : MessageLookupByLibrary.simpleMessage("Algo salió mal"),
    "signIn" : MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
    "revisionDescription" : MessageLookupByLibrary.simpleMessage("Revisión de la descripción"),
    "revisionDescriptionSubmitted" : MessageLookupByLibrary.simpleMessage("Revisión de la descripción enviada"),
    "editHarvest" : MessageLookupByLibrary.simpleMessage("Editar cosecha"),
    "welcomeToFacePunch" : MessageLookupByLibrary.simpleMessage("Bienvenido a Facepunch"),
    "theBestEmployeeClockingSystem" : MessageLookupByLibrary.simpleMessage("El mejor sistema de fichaje de empleados"),
    "employeePortal" : MessageLookupByLibrary.simpleMessage("Portal del empleado"),
    "team" : MessageLookupByLibrary.simpleMessage("Equipo"),
    "my" : MessageLookupByLibrary.simpleMessage("Mi"),
    "day" : MessageLookupByLibrary.simpleMessage("Día"),
  };
}
