﻿
Процедура ПередЗаписью(Отказ, РежимЗаписи)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Регистратор = ЭтотОбъект.Отбор.Регистратор.Значение;
	
	Если ОбщегоНазначения.ЕстьРеквизитДокумента("РучнаяКорректировка", Регистратор.Метаданные())
		И Регистратор.РучнаяКорректировка Тогда
		Возврат;
	КонецЕсли;
	
	Если Количество()>0 Тогда
		Заголовок = СокрЛП(Регистратор);
	Иначе
		Возврат;
	КонецЕсли; 
	
	КэшУчПолитики = Новый Соответствие;
	КэшУчПолитикиУСНиИП = Новый Соответствие;
	ВидыСоставныхСубконто = новый соответствие;
	
	ТипРегистратора = ТипЗнч(Регистратор);
	НеКорректироватьНалоговыеСуммыРегистратора = 
	ТипРегистратора = Тип("ДокументСсылка.ОперацияБух") 
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.МодернизацияОС")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.СписаниеОС")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.СписаниеНМА")
	// {ОбособленныеПодразделения
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоПрочееВходящее")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоПрочееИсходящее")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоОСВходящее")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоОСИсходящее")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоМПЗВходящее")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоМПЗИсходящее")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоРасчетыВходящее")
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.АвизоРасчетыИсходящее")
	// }ОбособленныеПодразделения 
	ИЛИ ТипРегистратора = Тип("ДокументСсылка.ВводНачальныхОстатков")
	ИЛИ (ТипРегистратора = Тип("ДокументСсылка.РегламентнаяОперация") 
		И Регистратор.ВидОперации <> Перечисления.ВидыРегламентныхОпераций.КорректировкаСтоимостиНоменклатуры
		И Регистратор.ВидОперации <> Перечисления.ВидыРегламентныхОпераций.ЗакрытиеСчета97);
		
	Если НеКорректироватьНалоговыеСуммыРегистратора Тогда
		Возврат;
		
	КонецЕсли;
	
	Для Каждого Проводка Из ЭтотОбъект Цикл
		
		СчетДт = Проводка.СчетДт;
		СчетКт = Проводка.СчетКт;
		
		// Ведение налогового учета и учета разниц
		
		ПрименениеУСНиИП = ПолучитьПрименениеУСНиИП(Проводка.Организация, Проводка.Период, КэшУчПолитикиУСНиИП);
		
		Если ПрименениеУСНиИП Тогда
			Проводка.СуммаНУДт = 0;
			Проводка.СуммаНУКт = 0;
			Проводка.СуммаПРДт = 0;
			Проводка.СуммаПРКт = 0;
			Проводка.СуммаВРДт = 0;
			Проводка.СуммаВРКт = 0;
			Продолжить;
		КонецЕсли;
				
		Если НЕ ЗначениеЗаполнено(СчетДт) И НЕ СчетКт.Забалансовый Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Проводка № "+(Проводка.НомерСтроки+1) +" <"+Проводка.Содержание+">: не заполнен счет дебета.",Отказ,Заголовок);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СчетКт) И НЕ СчетДт.Забалансовый Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Проводка № "+(Проводка.НомерСтроки+1) +" <"+Проводка.Содержание+">: не заполнен счет кредита.",Отказ,Заголовок);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СчетДт) И СчетДт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.ЦелевоеФинансирование) 
			ИЛИ ЗначениеЗаполнено(СчетКт) И СчетКт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.ЦелевоеФинансирование) Тогда
			Продолжить;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СчетДт) И (СчетДт = ПланыСчетов.Хозрасчетный.ПрочиеРасходы Или СчетДт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.ПрочиеРасходы))
			И (СчетКт = ПланыСчетов.Хозрасчетный.НДС Или СчетДт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.НДС) ИЛИ СчетКт = ПланыСчетов.Хозрасчетный.НДСНачисленныйПоОтгрузке) Тогда
			
			КорректироватьСуммы = Ложь;
			Для Каждого Субконто Из Проводка.СубконтоДт Цикл
				Если ТипЗнч(Субконто.Значение) = Тип("СправочникСсылка.ПрочиеДоходыИРасходы") 
					И (Субконто.Значение.ВидПрочихДоходовИРасходов = Перечисления.ВидыПрочихДоходовИРасходов.КурсовыеРазницыПоРасчетамВУЕ Или
					 Субконто.Значение.ВидПрочихДоходовИРасходов = Перечисления.ВидыПрочихДоходовИРасходов.ШтрафыПениНеустойкиКПолучениюУплате Или
					 Субконто.Значение.ВидПрочихДоходовИРасходов = Перечисления.ВидыПрочихДоходовИРасходов.РасходыПоПередачеТоваровБезвозмездноИДляСобственныхНужд) Тогда
					КорректироватьСуммы = Истина;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если НЕ КорректироватьСуммы Тогда
				Продолжить;
			КонецЕсли;
				
		КонецЕсли;
		
		// Приведение пустых значений субконто составного типа.
		Для Каждого Субконто Из Проводка.СубконтоДт Цикл
			Составной = ВидыСоставныхСубконто.Получить(Субконто.Ключ);          //
			Если Составной=неопределено Тогда                                   //  
				Составной = Субконто.Ключ.ТипЗначения.Типы().Количество() > 1;  // Кэширование: вид субконто + признак Составной
				ВидыСоставныхСубконто.Вставить(Субконто.Ключ,Составной);        //
			КонецЕсли;                                                          //
			Если Составной
				И НЕ ЗначениеЗаполнено(Субконто.Значение) 
				И НЕ (Субконто.Значение = Неопределено) Тогда
				Проводка.СубконтоДт.Вставить(Субконто.Ключ, Неопределено);
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого Субконто Из Проводка.СубконтоКт Цикл
			Составной = ВидыСоставныхСубконто.Получить(Субконто.Ключ);          //
			Если Составной=неопределено Тогда                                   //  
				Составной = Субконто.Ключ.ТипЗначения.Типы().Количество() > 1;  // Кэширование: вид субконто + признак Составной
				ВидыСоставныхСубконто.Вставить(Субконто.Ключ,Составной);        //
			КонецЕсли;                                                          //
			Если Составной
				И НЕ ЗначениеЗаполнено(Субконто.Значение) 
				И НЕ (Субконто.Значение = Неопределено) Тогда
				Проводка.СубконтоКт.Вставить(Субконто.Ключ, Неопределено);
			КонецЕсли;
		КонецЦикла;
		
		Если ЕстьДоходыРасходыОтПродажиВалюты(Проводка) Тогда
			Проводка.СуммаНУДт = 0;
			Проводка.СуммаНУКт = 0;
			Проводка.СуммаПРДт = 0;
			Проводка.СуммаПРКт = 0;
			Проводка.СуммаВРДт = 0;
			Проводка.СуммаВРКт = 0;
			Продолжить;
		КонецЕсли;
		
		Если СчетДт = ПланыСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный
			ИЛИ СчетДт = ПланыСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный
			ИЛИ СчетКт = ПланыСчетов.Хозрасчетный.СпецодеждаВЭксплуатацииВспомогательный
			ИЛИ СчетКт = ПланыСчетов.Хозрасчетный.СпецоснасткаВЭксплуатацииВспомогательный Тогда
			Продолжить;
		КонецЕсли;
		
		Если СчетДт.НалоговыйУчет И Проводка.СуммаНУДт = 0 И Проводка.СуммаПРДт = 0 И Проводка.СуммаВРДт = 0 Тогда
			Проводка.СуммаНУДт = Проводка.Сумма;
		КонецЕсли;
		
		Если СчетКт.НалоговыйУчет И Проводка.СуммаНУКт = 0 И Проводка.СуммаПРКт = 0 И Проводка.СуммаВРКт = 0 Тогда
			Проводка.СуммаНУКт = Проводка.Сумма;
		КонецЕсли;
			
		Если СчетКт.НалоговыйУчет Тогда
			
			ЭтоНепринимаемыеДоходы = НалоговыйУчет.ОпределитьНеПринимаемыеДоходы(Проводка);
			Если ЭтоНепринимаемыеДоходы Тогда 
				Проводка.СуммаПРКт = Проводка.СуммаПРКт + Проводка.СуммаНУКт;
				Проводка.СуммаНУКт = 0;
			КонецЕсли;
			
		КонецЕсли;
		
		Если СчетДт.НалоговыйУчет Тогда
			
			ЭтоНепринимаемыеРасходы = НалоговыйУчет.ОпределитьНеПринимаемыеРасходы(Проводка);
			Если ЭтоНепринимаемыеРасходы Тогда 
				Проводка.СуммаПРДт = Проводка.СуммаПРДт + Проводка.СуммаНУДт;
				Проводка.СуммаНУДт = 0;
			КонецЕсли;
			
		КонецЕсли;
		
		ПоддержкаПБУ18 = ПолучитьПрименениеПБУ18(Проводка.Организация, Проводка.Период, КэшУчПолитики);
		Если Не ПоддержкаПБУ18 Тогда
			Проводка.СуммаПРДт = 0;
			Проводка.СуммаВРДт = 0;
			Проводка.СуммаПРКт = 0;
			Проводка.СуммаВРКт = 0;
		КонецЕсли;
		
	НепринимаемыеДоходыИРасходы(Проводка);
		
	КонецЦикла;
	
	
КонецПроцедуры

Функция ПолучитьПрименениеПБУ18 (Организация, Период, КэшУчПолитики)
	
	Если КэшУчПолитики.Количество() = 0 Тогда
		ПоддержкаПБУ18 = НалоговыйУчет.ПрименениеПБУ18(Организация, Период);
		КэшУчПолитики.Вставить(Период, ПоддержкаПБУ18);
	Иначе ПоддержкаПБУ18 = КэшУчПолитики.Получить(Период);
		Если ПоддержкаПБУ18 = Неопределено Тогда
			ПоддержкаПБУ18 = НалоговыйУчет.ПрименениеПБУ18(Организация, Период);
			КэшУчПолитики.Вставить(Период, ПоддержкаПБУ18);
		КонецЕсли;
	КонецЕсли;
	
	Возврат ПоддержкаПБУ18;	
	
КонецФункции

Функция ПолучитьПрименениеУСНиИП (Организация, Период, КэшУчПолитики)
	
	Если КэшУчПолитики.Количество() = 0 Тогда
		ПрименениеУСНиИП = НалоговыйУчетУСН.ПрименениеУСН(Организация, Период) Или ОбщегоНазначения.Предприниматель(Организация, Период);
		КэшУчПолитики.Вставить(Период, ПрименениеУСНиИП);
	Иначе ПрименениеУСНиИП = КэшУчПолитики.Получить(Период);
		Если ПрименениеУСНиИП = Неопределено Тогда
			ПрименениеУСНиИП = НалоговыйУчетУСН.ПрименениеУСН(Организация, Период) Или ОбщегоНазначения.Предприниматель(Организация, Период);
			КэшУчПолитики.Вставить(Период, ПрименениеУСНиИП);
		КонецЕсли;
	КонецЕсли;
	
	Возврат ПрименениеУСНиИП;	
	
КонецФункции

// Доходы и расходы от продажи валюты в НУ отражаются особым образом.
// Проводки со статьей "Доходы (расходы), связанные с продажей (покупкой) валюты" в НУ не отражаются
//
Функция ЕстьДоходыРасходыОтПродажиВалюты(Проводка)
	
	СтатьяДоходовРасходовОтПродажиВалюты = Справочники.ПрочиеДоходыИРасходы.ДоходыРасходыПриПродажеПокупкеВалюты;
	
	Для каждого Субконто Из Проводка.СубконтоДт Цикл
		Если Субконто.Значение = СтатьяДоходовРасходовОтПродажиВалюты Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Для каждого Субконто Из Проводка.СубконтоКт Цикл
		Если Субконто.Значение = СтатьяДоходовРасходовОтПродажиВалюты Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции // ()


Процедура НепринимаемыеДоходыИРасходы(Проводка)
	
	Если Не Проводка.СчетКт = ПланыСчетов.Хозрасчетный.ПустаяСсылка() И (Проводка.СчетКт = ПланыСчетов.Хозрасчетный.ПрочиеДоходы Или Проводка.СчетКт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.ПрочиеДоходы)) Тогда
		
		ОтразитьНеПринимаемыеДоходы = НалоговыйУчет.ОпределитьНеПринимаемыеДоходыРасходы(Проводка);
	Иначе
		ОтразитьНеПринимаемыеДоходы = Ложь;
	КонецЕсли;
	
	Если  Проводка.СуммаПРКт <> 0 Или Проводка.СуммаВРКт <> 0 Или Проводка.СуммаВРДт <> 0 Тогда
		
		ОтразитьНеПринимаемыеРасходы = Ложь;
		
	Иначе 
		ОтразитьНеПринимаемыеРасходы = НалоговыйУчет.ОпределитьНеПринимаемыеДоходыРасходы(Проводка);
		
	КонецЕсли;
	
	
	Если ОтразитьНеПринимаемыеРасходы Тогда 
		ПроводкаПоНеПринимаемымРасходам = ЭтотОбъект.Добавить();
		ПроводкаПоНеПринимаемымРасходам.Организация = Проводка.Организация;
		ПроводкаПоНеПринимаемымРасходам.Период      = Проводка.Период;
		ПроводкаПоНеПринимаемымРасходам.Содержание  = Проводка.Содержание;
		ПроводкаПоНеПринимаемымРасходам.СуммаНУДт   = Проводка.Сумма;
		
		Если НалоговыйУчет.ОпределитьВнереализационныеДоходыРасходы(Проводка) Тогда
			СчетУчетаНепринимаемыхРасходов     =   ПланыСчетов.Хозрасчетный.ВнереализационныеРасходыНеУчитываемые;
		ИначеЕсли Проводка.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПерсоналомПоОплатеТруда Или Проводка.СчетКт = ПланыСчетов.Хозрасчетный.РасчетыСПерсоналомПоОплатеТруда Тогда
			СчетУчетаНепринимаемыхРасходов     =  ПланыСчетов.Хозрасчетный.ВыплатыВпользуФизЛицПоП_1_48;
		ИначеЕсли Проводка.СчетДт = ПланыСчетов.Хозрасчетный.ПрочиеРасходы И Проводка.СчетКт = ПланыСчетов.Хозрасчетный.НДС Тогда // НДС с разниц при расчетах в уе
			СчетУчетаНепринимаемыхРасходов     =  ПланыСчетов.Хозрасчетный.ДругиеВыплатыПоП_49;
		Иначе
			СчетУчетаНепринимаемыхРасходов     =  ПланыСчетов.Хозрасчетный.ДругиеВыплатыПоП_1_48;
		КонецЕсли;
		
		ОтразитьНеПринимаемыеРасходы(ПроводкаПоНеПринимаемымРасходам, СчетУчетаНепринимаемыхРасходов);
	КонецЕсли;
	
	Если ОтразитьНеПринимаемыеДоходы Тогда 
		
		ПроводкаПоНеПринимаемымДоходам = ЭтотОбъект.Добавить();
		ПроводкаПоНеПринимаемымДоходам.Организация = Проводка.Организация;
		ПроводкаПоНеПринимаемымДоходам.Период      = Проводка.Период;
		ПроводкаПоНеПринимаемымДоходам.Содержание  = Проводка.Содержание;
		ПроводкаПоНеПринимаемымДоходам.СуммаНУКт   = Проводка.Сумма;
		
		ОтразитьНеПринимаемыеДоходы(ПроводкаПоНеПринимаемымДоходам);
	КонецЕсли;
КонецПроцедуры
	
Процедура ОтразитьНеПринимаемыеРасходы(Проводка, СчетУчетаНепринимаемыхРасходов)
	
	Проводка.КоличествоДт = 0;
	Проводка.СчетДт       =  СчетУчетаНепринимаемыхРасходов;
	Проводка.СубконтоДт.Очистить();	

	
КонецПроцедуры

Процедура ОтразитьНеПринимаемыеДоходы(Проводка)
	
	Проводка.КоличествоКт = 0;
	Проводка.СчетКт       =  ПланыСчетов.Хозрасчетный.ДоходыНеУчитываемые;
	Проводка.СубконтоКт.Очистить();	
	
КонецПроцедуры
