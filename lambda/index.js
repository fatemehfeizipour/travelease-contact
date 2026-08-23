exports.handler = async (event) => {
    console.log("received event:", event);

    return {
        statusCode: 200,
        headers: {
            "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify({ message: "success"})
    };
};
