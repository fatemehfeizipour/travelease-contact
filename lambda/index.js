    const crypto = require("crypto");

    const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
    const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

exports.handler = async (event) => {
    console.log("received event:", event);
    const formData = JSON.parse(event.body);
    if (formData.website !=="") {
        return{
            statusCode: 200,
             headers: {
            "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify({ message: "received"})
        }
    }

    // after the honeypot check

    const errors = [];
    if (!formData.fullName){
        errors.push("Full name is required");
    }
    if (!formData.email){
        errors.push("Email is required")
    }
    else if (!formData.email.includes("@")){
        errors.push("Email format is required")
    }
     if (!formData.phone){
        errors.push("Phone number is required");
    }
     if (!formData.howFoundUs){
        errors.push("How you found us");
    }
    if (!formData.customerType){
        errors.push("new/returning");
    }

    if(errors.length >0){
        return {
        statusCode: 400,
        headers: {
            "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify({ message: "errors"})
    };
        }
        
        
       
        const referenceNumber = crypto.randomUUID();

       // DynamoDB write — no try/catch, let it crash naturally if it fails

        const client = new DynamoDBClient({});

        await client.send(new PutItemCommand({
        TableName: process.env.TABLE_NAME,
        Item: {
            submission_id: { S: referenceNumber },
            fullName: { S: formData.fullName },
            email: { S: formData.email },
            phone: { S: formData.phone },
            howFoundUs: { S: formData.howFoundUs },
            customerType: { S: formData.customerType }
        }
        }));


        //SES

        const sesClient = new SESClient({});

         // Customer confirmation email — wrapped, errors caught and swallowed
        try{
             await sesClient.send(new SendEmailCommand({
            Source: "fatemehfeizipur@gmail.com",
            Destination: {
                ToAddresses: [formData.email],
            },
            Message: {
                Subject: { Data: "received"},
                Body: {
                    Text: {Data: `Thank you for your inquiry! Your reference number is ${referenceNumber}.`},
                }
            }
        }))
        } catch(err) {
            console.log('customer email failed:', err);
        }
        

        // Business Notification Email

        try{
            await sesClient.send(new SendEmailCommand({
            Source: "fatemehfeizipur@gmail.com",
            Destination: {
                ToAddresses: ["fatemehfeizipur@gmail.com"],
            },
            Message: {
                Subject: { Data: "form submitted"},
                Body: {
                    Text: {Data: `a contact form is submitted!
                        Reference number: ${referenceNumber}
                        Fullname: ${formData.fullName}
                        Email: ${formData.email}
                        Phone: ${formData.phone}
                        How found us: ${formData.howFoundUs}
                        Customer Type: ${formData.customerType}
                        .`},
                }
            }
        }));
        } catch(err) {
            console.log('business email failed:', err);
        }
        
        //The final return
        return{
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Origin": "*"
            },
            body: JSON.stringify({ message: "Thank you! Your reference number is"+ referenceNumber +"Submission received successfully"})
}


    }

    

