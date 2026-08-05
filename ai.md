
# 📘 الدليل الهندسي المُحدّث لإدخال البيانات التاريخية في نظام (SakanOS)

## 1️⃣ القاعدة الذهبية: التطابق بين التطبيق المحلي (Drift) والسحابة (Supabase)

**الذكاء الاصطناعي يجب أن يعلم أن هناك فرقاً بين هيكلية قاعدة البيانات في كود التطبيق (Drift) وبين هيكلية السحابة (Supabase):**

* **لا تستخدم عمود** **is_synced**: **هذا العمود موجود فقط في الجداول المحلية (في كود فلاتر) ليراقب حالة المزامنة، ولا يتم رفعه للسحابة.**
* **تأكد من** **created_at** **و** **updated_at**: **انتبه بشدة! جدول** **payments** **في Supabase** **لا يحتوي** **على عمود** **created_at** **نهائياً (يحتوي فقط على** **updated_at**). بينما باقي الجداول تحتوي على الاثنين.

## 2️⃣ التسلسل الهرمي للإدخال (Relational Hierarchy)

**يجب إدخال البيانات بصرامة حسب هذا الترتيب للحفاظ على المفاتيح الأجنبية (Foreign Keys):**

* **المحضر (buildings) ⬅️ 2. الشقة (apartments) ⬅️ 3. العميل (clients) ⬅️ 4. العقد (contracts) ⬅️ 5. المدفوعات (payments) ⬅️ 6. الجدولة (installments_schedule).**

## 3️⃣ الحيلة المحاسبية لإدخال أسعار المتر التاريخية (The Magic Snapshot)

**لتسهيل إدخال عقود تاريخية بأسعار متر ثابتة تم الاتفاق عليها مسبقاً، يجب إجبار النظام على تجاهل المواد واستخدام "السعر اليدوي". يتم ذلك عن طريق إرسال هذا الـ JSON داخل عمود** **prices_snapshot** **في جدول المدفوعات** **payments**:
'{"note": "إدخال تاريخي سريع", "manual_meter_price": <سعر_المتر>}'

## 4️⃣ ضرورة ملء حقول الـ JSON الهندسية (المحاضر والشقق)

 **تطبيق Flutter يعتمد على حقول الـ JSON لرسم واجهة الطوابق والمحلات.** **يُمنع تركها فارغة** **{}** **إذا كان العقد متخصصاً**.

* **في جدول** **buildings**: **يجب تمرير** **floor_coefficients** **(مثل** **'{"الطابق الأول": 6}'**) وتمرير **direction_coefficients** **(مثل** **'{"الموقع": 10.4, "الشارع": 4.8}'**).
* **في جدول** **apartments**: **يجب تمرير** **custom_coefficients** **(مثل** **'{"معامل التميز للوجيبة": 4.8}'**).

---

# 🤖 "موجه الذكاء الاصطناعي" (AI Prompt Template)

**ملاحظة: إذا أردت الانتقال لذكاء اصطناعي آخر، فقط انسخ له هذا النص الحرفي أدناه وأرفق معه ملف الإكسل:**

> **"أنا أقوم بترحيل بيانات تاريخية من ملف Excel إلى قاعدة بيانات Supabase (PostgreSQL) خاصة بنظام إدارة أملاك (ERP) مبني بـ Flutter.**
>
> **الرجاء كتابة سكربت SQL من نوع (PL/pgSQL Block) باستخدام** **DO** 
>
> **;** **لإدخال البيانات.**
>
> **تعليمات صارمة لكتابة السكربت:**
>
> * **استخدم دالة** **gen_random_uuid()** **لتوليد الـ IDs وقم بتخزينها في متغيرات لربط الجداول (Foreign Keys).**
> * **يوجد متغير ثابت للموظف** **v_user_id UUID := '0cb2878f-cce2-4cdc-8336-2743f51ba54b';** **استخدمه في كل الجداول.**
> * **حقل** **is_deleted** **يجب أن يكون دائماً** **false**.
> * **لا تقم بإضافة عمود اسمه** **is_synced** **أبداً.**
> * **بالنسبة لتواريخ الدفع، استخدم صيغة** **'YYYY-MM-DD'::TIMESTAMP**.
> * **في جدول** **payments**، اجعل حقل **prices_snapshot** **يحتوي على:** **'{"note": "إدخال تاريخي سريع", "manual_meter_price": <السعر_في_الاكسل>}'**
> * **انتبه جداً:** **جدول** **payments** **لا يحتوي على عمود** **created_at**، استخدم **updated_at** **فقط.**
> * **قم بتوليد رقم إيصال متسلسل** **receipt_number** **في جدول** **payments** **يبدأ من 1000.**
> * **قم بتحويل أسماء العملاء والكفلاء إلى أسماء إنجليزية عشوائية (Data Anonymization).**
>
> **هيكلية الجداول المتاحة في السحابة هي كالتالي (استخدم هذه الأعمدة حرفياً):**
>
> * **buildings**: id, name, location, floor_coefficients, direction_coefficients, user_id, is_deleted, created_at, updated_at
> * **apartments**: id, building_id, apartment_number, area, floor_name, direction_name, custom_coefficients, status, user_id, is_deleted, created_at, updated_at, unit_type
> * **clients**: id, name, phone, national_id, is_deleted, updated_at, user_id, created_at
> * **contracts**: id, client_id, contract_type, apartment_details, total_area, base_meter_price_at_signing, coefficients, contract_date, is_completed, is_deleted, updated_at, installments_count, user_id, guarantor_name, contract_file_url, apartment_id, agreed_monthly_amount, last_action_date, last_action_note, down_payment, is_handed_over, agreed_handover_date, actual_handover_date, grace_period_months, handover_notes, is_penalty_active, penalty_percentage, penalty_interval_months, created_at
> * **payments**: id, contract_id, schedule_id, payment_date, amount_paid, meter_price_at_payment, converted_meters, fees, is_whatsapp_sent, is_deleted, updated_at, user_id, prices_snapshot, receipt_number
> * **installments_schedule**: id, contract_id, installment_number, due_date, status, is_deleted, updated_at, created_at, user_id, notes, last_action_date, last_action_note, expected_amount
>
> **كيف تتعامل مع نوع العقد:**
>
> * **إذا كان العقد** **"متخصص"**: يجب إدخال المحضر (buildings) ثم الشقة (apartments) ثم العقد (contracts). وحالة الشقة يجب أن تكون **status = 'sold'**. **(يجب ملء حقول الـ JSON الهندسية للمحضر والشقة من الإكسل لكي يقرأها كود Flutter).**
> * **إذا كان العقد** **"لاحق التخصص"**: تجاهل جدولي المحاضر والشقق تماماً. قم بإنشاء العميل (clients) ثم العقد مباشرة. وفي جدول العقد اجعل **apartment_id** **قيمته** **NULL** **والوصف** **apartment_details** **قيمته "أسهم استثمارية غير مخصصة".**
>
> **إليك بيانات الإكسل التي أريد تحويلها إلى SQL:**
> [هنا تقوم بلصق بيانات العميل الجديد من الإكسل]"

---

**الآن، هذه النسخة تعتبر "دليلاً مثالياً". يمكنك استخدامه مع أي ملف إكسل قادم!**

**هل نبدأ بترحيل بيانات** **العقد الثاني (عقد لاحق التخصص)** **الموجود في الصورة لديك؟ أرسل لي الأرقام أو دعني أستخرجها من الصورة التي أرسلتها سابقاً لنبدأ فوراً! 🚀**
