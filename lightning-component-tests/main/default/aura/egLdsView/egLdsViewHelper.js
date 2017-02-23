({
    validateContactForm: function(component) {
        var validContact = true;

        // First and Last Name are required
        var firstNameField = component.find("contactFirstName");
        if($A.util.isEmpty(firstNameField.get("v.value"))) {
            validContact = false;
            firstNameField.set("v.errors", [{message:"First name can't be blank"}]);
        }
        else {
            firstNameField.set("v.errors", null);
        }
        var lastNameField = component.find("contactLastName");
        if($A.util.isEmpty(lastNameField.get("v.value"))) {
            validContact = false;
            lastNameField.set("v.errors", [{message:"Last name can't be blank"}]);
        }
        else {
            lastNameField.set("v.errors", null);
        }

        // Verify we have an account to attach it to
        var account = component.get("v.account");
        if($A.util.isEmpty(account)) {
            validContact = false;
            console.log("Quick action context doesn't have a valid account.");
        }

        // TODO: (Maybe) Validate email and phone number

        return validContact;
    }
})